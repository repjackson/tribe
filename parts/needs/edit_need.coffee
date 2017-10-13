FlowRouter.route '/edit_need/:need_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_need'



if Meteor.isClient
    Template.edit_need.onCreated ->
        @autorun -> Meteor.subscribe 'need', FlowRouter.getParam('need_id')
        @autorun -> Meteor.subscribe 'usernames'
    
    
    Template.edit_need.helpers
        need: -> Needs.findOne FlowRouter.getParam('need_id')
        
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

            
    Template.edit_need.events
        'click #save': ->
            FlowRouter.go "/"


        'keydown #add_tag': (e,t)->
            if e.which is 13
                need_id = FlowRouter.getParam('need_id')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Needs.update need_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
    
        'click .need_tag': (e,t)->
            tag = @valueOf()
            Needs.update FlowRouter.getParam('need_id'),
                $pull: tags: tag
            $('#add_tag').val(tag)


        # 'autocompleteselect #search': (event, template, user) ->
        #     console.log 'selected ', user
        #     Needs.update FlowRouter.getParam('need_id'),
        #         $addToSet: 
        #             user_ids: user._id

        'blur #need_description': ->
            description = $('#need_description').val()
            Needs.update FlowRouter.getParam('need_id'),
                $set: description: description