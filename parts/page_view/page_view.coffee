FlowRouter.route '/view/:deed_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'page_view'



if Meteor.isClient
    Template.page_view.onCreated ->
        @autorun -> Meteor.subscribe 'deed', FlowRouter.getParam('deed_id')
    
    
    
    Template.page_view.helpers
        deed: ->
            Deeds.findOne FlowRouter.getParam('deed_id')
    

    
    Template.page_view.events
        'click .edit': ->
            deed_id = FlowRouter.getParam('deed_id')
            FlowRouter.go "/edit/#{deed_id}"