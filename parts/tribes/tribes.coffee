@Tribes = new Meteor.Collection 'tribes'

Tribes.before.insert (userId, tribe)->
    tribe.timestamp = Date.now()
    tribe.author_id = Meteor.userId()
    tribe.members = [Meteor.userId()]
    return

Tribes.after.update ((userId, tribe, fieldNames, modifier, options) ->
    tribe.tag_count = tribe.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Tribes.helpers
    author: -> Meteor.users.findOne @author_id
    members: -> Meteor.users.find _id: $in: @members
    when: -> moment(@timestamp).fromNow()

FlowRouter.route '/tribes', action: (params) ->
    BlazeLayout.render 'layout',
        cloud: 'cloud'
        main: 'tribes'

Meteor.methods
    add_tribe: (tags=[])->
        id = Tribes.insert
            tags: tags
        return id


if Meteor.isClient
    Template.tribes.onCreated -> 
        @autorun -> Meteor.subscribe('tribes', selected_tags.array())

    Template.tribes.helpers
        tribes: -> 
            Tribes.find { }, 
                sort:
                    tag_count: 1
                limit: 5
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'


    
    Template.tribe_card_view.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        when: -> moment(@timestamp).fromNow()

    Template.tribe_card_view.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
    
        'click .edit': -> FlowRouter.go("/edit_tribe/#{@_id}")

    Template.tribes.events
        'click #add_tribe': ->
            Meteor.call 'add_tribe', (err,id)->
                FlowRouter.go "/edit_tribe/#{id}"

