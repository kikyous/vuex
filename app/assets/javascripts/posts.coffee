# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  window.vm = new Vue(
    el: '#main'
    data:
      view: 'c-wel'
      id: null
      current_page: 1
    filters:
      tomarked: marked
    components:
      'c-wel':
        template: 'welcome to vuex'
      'c-index':
        props: ['current_page']
        data: ->
          current_page: 1
          posts: []
        computed:
          pages: ->
            _.reject (_.uniq [1, @current_page-2, @current_page-1, @current_page, @current_page+1, @current_page+2]), (i)->
              i<1
        template: '#index'
        watch:
          'current_page': ->
            this.fetchPosts()

        compiled: ->
          this.fetchPosts()
        methods:
          fetchPosts: ->
            self = this
            $.ajax
              url: "/posts.json?page=#{self.current_page}"
              success: (data, status, xhr)->
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
  posts = (params)->
    if /\?/.test(window.location.href)
      current_page = +_.object([window.location.href.split('?')[1].split('=')])['page']
    else
      current_page = 1
    vm.view = 'c-index'
    vm.current_page = current_page
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
    '/posts': posts
    '/posts/new': newPost
    '/posts/:postId': showPost
    '/posts/:postId/edit': editPost

  router = Router(routes).configure({html5history: true})

  router.init()

  $(document).on 'click', 'a', (e)->
    e.preventDefault()
    router.setRoute($(@).attr('href'))
