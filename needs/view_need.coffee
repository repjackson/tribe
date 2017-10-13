FlowRouter.route '/view_need/:need_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_need'



if Meteor.isClient
    Template.view_need.onCreated ->
        @autorun -> Meteor.subscribe 'need', FlowRouter.getParam('need_id')
    
    
    
    Template.view_need.helpers
        need: -> Needs.findOne FlowRouter.getParam('need_id')
    

    
    Template.view_need.events