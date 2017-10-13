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
        @autorun => Meteor.subscribe('needs')

    Template.needs.helpers
        needs: -> Needs.find {}
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
    Template.needs.events
        'click #add_need': ->
            Meteor.call 'add_need', (err,id)->
                FlowRouter.go "/edit_need/#{id}"
    
    Template.need_card.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        when: -> moment(@timestamp).fromNow()

    Template.need_card.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
        'click .edit': -> FlowRouter.go("/edit_need/#{@_id}")


if Meteor.isServer
    Meteor.publish 'needs', ()->
        self = @
        Needs.find {}
