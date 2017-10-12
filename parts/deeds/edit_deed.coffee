FlowRouter.route '/edit_deed/:deed_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_deed'



if Meteor.isClient
    Template.edit_deed.onCreated ->
        @autorun -> Meteor.subscribe 'deed', FlowRouter.getParam('deed_id')
        @autorun -> Meteor.subscribe 'usernames'
    
    
    Template.edit_deed.helpers
        deed: -> Deeds.findOne FlowRouter.getParam('deed_id')
        
        users: ->
            Meteor.users.find
                _id: $in: @user_ids
        
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Meteor.users
                    field: 'username'
                    matchAll: true
                    template: Template.user_result
                }
                ]
        }

            
    Template.edit_deed.events
        'click #save': ->
            FlowRouter.go "/view_tribe/#{@tribe_id}"


        'keydown #add_tag': (e,t)->
            if e.which is 13
                deed_id = FlowRouter.getParam('deed_id')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Deeds.update deed_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
    
        'click .deed_tag': (e,t)->
            tag = @valueOf()
            Deeds.update FlowRouter.getParam('deed_id'),
                $pull: tags: tag
            $('#add_tag').val(tag)


        'autocompleteselect #search': (event, template, user) ->
            console.log 'selected ', user
            Deeds.update FlowRouter.getParam('deed_id'),
                $addToSet: 
                    user_ids: user._id

        'click .remove_user': ->
            Deeds.update FlowRouter.getParam('deed_id'),
                $pull: user_ids: @_id