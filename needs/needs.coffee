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
        @autorun -> Meteor.subscribe('facet', selected_tags.array(), selected_author_ids.array())
    Template.need_card.onCreated -> 
        @autorun => Meteor.subscribe('user',  @data.author_id)

    Template.needs.helpers
        needs: -> Needs.find {}
    
    Template.needs.events
        'click #add_need': ->
            Meteor.call 'add_need', (err,id)->
                FlowRouter.go "/edit_need/#{id}"
        'click #logout': -> AccountsTemplates.logout()
        'keyup #quick_add': (e,t)->
            e.preventDefault
            tag = $('#quick_add').val().toLowerCase()
            if e.which is 13
                if tag.length > 0
                    split_tags = tag.match(/\S+/g)
                    $('#quick_add').val('')
                    Needs.insert
                        tags: split_tags
                    selected_tags.clear()
                    for tag in split_tags
                        selected_tags.push tag


    Template.need_card.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()
        need_tag_class: -> if @valueOf() in selected_tags.array() then 'active' else ''
        when: -> moment(@timestamp).fromNow()

    Template.need_card.events
        'click .need_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())


# if Meteor.isServer
#     Meteor.publish 'needs', (selected_tags)->
#         self = @
#         match = {}
#         if selected_tags.length > 0 then match.tags = $in: selected_tags
#         Needs.find match
