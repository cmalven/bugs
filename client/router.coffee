Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

Router.map ->

  @route 'index',
    path: '/',
    template: 'index'