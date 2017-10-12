Template.user_tribes.onCreated ->
    # console.log @data
    @autorun => Meteor.subscribe 'user_tribes', @data.user_id
    
Template.user_tribes.helpers
    user_tribes: ->
        Tribes.find
            members: $in: [Template.currentData().user_id]