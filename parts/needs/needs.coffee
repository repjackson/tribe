@Needs = new Meteor.Collection 'needs'

Needs.before.insert (userId, need)->
    need.timestamp = Date.now()
    need.author_id = Meteor.userId()
    return

Needs.after.update ((userId, need, fieldNames, modifier, options) ->
    need.tag_count = need.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Needs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'needs'

Meteor.methods
    add_need: ()->
        id = Needs.insert {}
        return id


if Meteor.isClient
    Template.needs.onCreated -> 
        @autorun => Meteor.subscribe('needs', selected_tags.array())

    Template.needs.helpers
        needs: -> Needs.find {}
    
    Template.needs.events
        'click #add_need': ->
            Meteor.call 'add_need', (err,id)->
                FlowRouter.go "/edit_need/#{id}"
    
    Template.need_card.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
        need_tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
        when: -> moment(@timestamp).fromNow()

    Template.need_card.events
        'click .need_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())


if Meteor.isServer
    Meteor.publish 'needs', (selected_tags)->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $in: selected_tags
        Needs.find match
