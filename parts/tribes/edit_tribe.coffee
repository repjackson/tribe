FlowRouter.route '/edit_tribe/:tribe_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_tribe'



if Meteor.isClient
    Template.edit_tribe.onCreated ->
        @autorun -> Meteor.subscribe 'tribe', FlowRouter.getParam('tribe_id')
        @autorun -> Meteor.subscribe 'tribe_members', FlowRouter.getParam('tribe_id')
    
    
    Template.edit_tribe.helpers
        tribe: ->
            Tribes.findOne FlowRouter.getParam('tribe_id')
        
    
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

            
    Template.edit_tribe.events
        'click #save': ->
            FlowRouter.go "/view_tribe/#{FlowRouter.getParam('tribe_id')}"

        'click #delete_tribe': ->
            if confirm "Delete #{name} Tribe?"
                Tribes.remove FlowRouter.getParam('tribe_id')
                FlowRouter.go '/tribes'

        'blur #tribe_name': ->
            name = $('#tribe_name').val()
            tribe_id = FlowRouter.getParam('tribe_id')
            Tribes.update tribe_id,
                $set: name: name 
            
            
            
        'keydown #add_tribe_tag': (e,t)->
            if e.which is 13
                tribe_id = FlowRouter.getParam('tribe_id')
                tag = $('#add_tribe_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Tribes.update tribe_id,
                        $addToSet: tags: tag
                    $('#add_tribe_tag').val('')
    
        'click .tribe_tag': (e,t)->
            tag = @valueOf()
            Tribes.update FlowRouter.getParam('tribe_id'),
                $pull: tags: tag
            $('#add_tribe_tag').val(tag)


        'autocompleteselect #search': (event, template, doc) ->
            console.log 'selected ', doc
            Tribes.update FlowRouter.getParam('tribe_id'),
                $set: 
                    user: doc._id
