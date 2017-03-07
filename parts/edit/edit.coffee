FlowRouter.route '/edit/:deed_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'



if Meteor.isClient
    Template.edit.onCreated ->
        @autorun -> Meteor.subscribe 'deed', FlowRouter.getParam('deed_id')
    
    
    Template.edit.helpers
        deed: ->
            Deeds.findOne FlowRouter.getParam('deed_id')
        
    
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

            
    Template.edit.events
        'click #save': ->
            FlowRouter.go "/view/#{FlowRouter.getParam('deed_id')}"


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


        'autocompleteselect #search': (event, template, doc) ->
            console.log 'selected ', doc
            Deeds.update FlowRouter.getParam('deed_id'),
                $set: 
                    user: doc._id
