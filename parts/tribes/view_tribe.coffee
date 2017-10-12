FlowRouter.route '/view_tribe/:tribe_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_tribe'



if Meteor.isClient
    Template.view_tribe.onCreated ->
        @autorun -> Meteor.subscribe 'tribe', FlowRouter.getParam('tribe_id')
        @autorun -> Meteor.subscribe 'tribe_members', FlowRouter.getParam('tribe_id')
    
    
    Template.view_tribe.helpers
        tribe: -> Tribes.findOne FlowRouter.getParam('tribe_id')
        
        members: ->
            tribe = Tribes.findOne FlowRouter.getParam('tribe_id')
            Meteor.users.find
                _id: $in: tribe.members
        
        in_tribe: ->
            Meteor.userId() in @members
        
        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Meteor.users
        #             field: 'username'
        #             matchAll: true
        #             template: Template.user_result
        #         }
        #         ]
        # }

            
    Template.view_tribe.events
        'click #leave_tribe': ->
            if confirm 'Leave Tribe?'
                Tribes.update FlowRouter.getParam('tribe_id'),
                    $pull: members: Meteor.userId()
                    
        'click #join_tribe': ->
            if confirm 'Join Tribe?'
                Tribes.update FlowRouter.getParam('tribe_id'),
                    $addToSet: members: Meteor.userId()
                    
                    