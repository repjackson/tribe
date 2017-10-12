@Deeds = new Meteor.Collection 'deeds'

Deeds.before.insert (userId, deed)->
    deed.timestamp = Date.now()
    deed.author_id = Meteor.userId()
    return

Deeds.after.update ((userId, deed, fieldNames, modifier, options) ->
    deed.tag_count = deed.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Deeds.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

FlowRouter.route '/deeds', action: (params) ->
    BlazeLayout.render 'layout',
        cloud: 'cloud'
        main: 'deeds'

Meteor.methods
    add: (tags=[])->
        id = Deeds.insert
            tags: tags
        return id


if Meteor.isClient
    Template.deeds.onCreated -> 
        @autorun -> Meteor.subscribe('deeds', selected_tags.array())

    Template.deeds.helpers
        deeds: -> 
            Deeds.find { }, 
                sort:
                    tag_count: 1
                limit: 5
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'


    
    Template.view.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        when: -> moment(@timestamp).fromNow()

    Template.view.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
    
        'click .edit': -> FlowRouter.go("/edit/#{@_id}")

    Template.deeds.events
        'click #add': ->
            Meteor.call 'add', (err,id)->
                FlowRouter.go "/edit/#{id}"

