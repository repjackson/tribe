Meteor.users.allow
    update: (userId, need, fields, modifier) ->
        # console.log 'user ' + userId + 'wants to modify need' + need._id
        if userId and need._id == userId
            # console.log 'user allowed to modify own account'
            true

Accounts.onCreateUser (options, user) ->
    # user.karma = 1
    user


Meteor.publish 'me', -> 
    Meteor.users.find @userId,
        fields: 
            credits: 1
            tags: 1

# Cloudinary.config
#     cloud_name: 'facet'
#     api_key: Meteor.settings.cloudinary_key
#     api_secret: Meteor.settings.cloudinary_secret


Meteor.publish 'usernames', ->
    Meteor.users.find {},
        fields:
            username: 1
            profile: 1
            tags: 1
    


Meteor.publish 'people', (selected_tags)->
    match = {}
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.tags = $all: selected_tags
    match._id = $ne: @userId
    Meteor.users.find match,
        fields: 
            profile: 1
            karma: 1





Needs.allow
    insert: (userId, need) -> true
    update: (userId, need) -> true
    remove: (userId, need) -> true


# Needs.allow
#     insert: (userId, need) -> need.author_id is userId
#     update: (userId, need) -> need.author_id is userId or Roles.userIsInRole(userId, 'admin')
#     remove: (userId, need) -> need.author_id is userId or Roles.userIsInRole(userId, 'admin')


Meteor.publish 'need', (id)->
    Needs.find id
    
    
Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    need_cloud = Needs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud

    need_cloud.forEach (need_tag, i) ->
        self.added 'tags', Random.id(),
            name: need_tag.name
            count: need_tag.count
            index: i

    self.ready()

