# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  window.vm = new Vue(
    el: '#main'
    data:
      view: 'c-wel'
      id: null
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
        compiled: ->
          self = this
          $.getJSON "/posts.json?page=#{self.currentPage}", (data)->
            self.posts = data
            self.$emit('data-loaded')
      'c-show':
        template: '#show'
        props: ['id']
        compiled: ->
          console.log 'c-show compiled'
        data: ->
          id: null
          content: ''
        watch:
          'id': (newVal, oldVal)->
            self = this
            if self.id
              $.getJSON "/posts/#{self.id}.json", (data)->
                self.$data = data
                self.$emit('data-loaded')

      'c-form':
        props: ['id']
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
                self.$emit('data-loaded')
            else
              self.$emit('data-loaded')
  )
  posts = ->
    vm.view = 'c-index'
  showPost = (id)->
    vm.view = 'c-show'
    vm.id = +id
  editPost = (id)->
    vm.view = 'c-form'
    vm.id = +id
  newPost = ->
    vm.view = 'c-form'
    vm.id = 0


  routes =
    '/': posts
    '/posts/': posts
    '/posts/new': newPost
    '/posts/:postId': showPost
    '/posts/:postId/edit': editPost

  router = Router(routes).configure({strict: false})

  router.init()
