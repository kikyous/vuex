# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  Vue.config.async = false
  window.vm = new Vue(
    el: '#main'
    data:
      view: 'c-wel'
    filters:
      tomarked: marked
    components:
      'c-wel':
        template: 'welcome to vuex'
      'c-index':
        data: ->
          currentPage: 1
          posts: []
        template: '#index'
        ready: ->
          self = this
          $.getJSON "/posts.json?page=#{self.currentPage}", (data)->
            self.posts = data
      'c-show':
        template: '#show'
        data: ->
          id: null
          content: ''
        watch:
          'id': (newVal, oldVal)->
            self = this
            if self.id
              $.getJSON "/posts/#{self.id}.json", (data)->
                self.$data = data

      'c-form':
        data: ->
          id: null
          title: ''
          content: ''
        template: '#form'
        methods:
          submit: (e)->
            e.preventDefault()
            $.ajax
              url: if this.id then "/posts/#{this.id}.json" else '/posts.json'
              method: if this.id then 'PUT' else 'POST'
              data:
                post: this.$data
              success: ->
                vm.view = 'c-index'
        watch:
          'id': (newVal, oldVal)->
            self = this
            if self.id
              $.getJSON "/posts/#{self.id}.json", (data)->
                self.$data = data
            else
                self.$data = {}
  )
  posts = ->
    vm.view = 'c-index'
    console.log 'index route'
  showPost = (id)->
    vm.view = 'c-show'
    vm.$.main.$data.id = +id
  editPost = (id)->
    vm.view = 'c-form'
    vm.$.main.$data.id = +id
  newPost = ->
    vm.view = 'c-form'


  routes =
    '/': posts
    '/posts/': posts
    '/posts/new': newPost
    '/posts/:postId': showPost
    '/posts/:postId/edit': editPost

  router = Router(routes).configure({strict: false})

  router.init()
