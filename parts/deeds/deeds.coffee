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
    tribe: -> Tribes.findOne @tribe_id

FlowRouter.route '/deeds', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'deeds'

Meteor.methods
    log_deed: (tribe_id)->
        id = Deeds.insert
            tribe_id: tribe_id
        return id


if Meteor.isClient
    Template.tribe_deeds.onCreated -> 
        @autorun => Meteor.subscribe('tribe_deeds', @data.tribe_id)

    Template.tribe_deeds.helpers
        tribe_deeds: -> Deeds.find tribe_id: Template.currentData().tribe_id
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'


    
    Template.deed_card.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        when: -> moment(@timestamp).fromNow()

    Template.deed_card.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
        'click .edit': -> FlowRouter.go("/edit_deed/#{@_id}")


if Meteor.isServer
    Meteor.publish 'tribe_deeds', (tribe_id)->
        self = @
        Deeds.find
            tribe_id: tribe_id
            
