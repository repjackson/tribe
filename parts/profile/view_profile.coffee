if Meteor.isClient
    Template.view_profile.onCreated ->
        @autorun -> Meteor.subscribe('user_profile', FlowRouter.getParam('user_id'))
    
    Template.view_profile.helpers
        person: -> Meteor.users.findOne(FlowRouter.getParam('user_id'))
    
        can_edit: -> FlowRouter.getParam('user_id') is Meteor.userId()
    
    
    Template.view_profile.events
        'click .tag': ->
            if @valueOf() in selected_people_tags.array() then selected_people_tags.remove @valueOf() else selected_people_tags.push @valueOf()




FlowRouter.route '/profile/view/:user_id?', action: (params) ->
    if not params.user_id then params.user_id = Meteor.userId()
    BlazeLayout.render 'layout',
        main: 'view_profile'



if Meteor.isServer
    Meteor.publish 'my_profile', ->
        Meteor.users.find @userId,
            fields:
                tags: 1
                profile: 1
                username: 1
                published: 1
                image_id: 1
        
        
        Meteor.publish 'user_profile', (id)->
        Meteor.users.find id,
            fields:
                tags: 1
                profile: 1
                username: 1
                published: 1
                image_id: 1
