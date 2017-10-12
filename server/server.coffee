Meteor.users.allow
    update: (userId, deed, fields, modifier) ->
        # console.log 'user ' + userId + 'wants to modify deed' + deed._id
        if userId and deed._id == userId
            # console.log 'user allowed to modify own account'
            true

Accounts.onCreateUser (options, user) ->
    user.karma = 1
    user


Meteor.publish 'me', -> 
    Meteor.users.find @userId,
        fields: 
            credits: 1
            tags: 1

Meteor.publish 'user_tribes', (user_id)->
    Tribes.find
        members: $in: [user_id]

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


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





Deeds.allow
    insert: (userId, deed) -> true
    update: (userId, deed) -> true
    remove: (userId, deed) -> true

Tribes.allow
    insert: (userId, tribe) -> true
    update: (userId, tribe) -> true
    remove: (userId, tribe) -> true

# Deeds.allow
#     insert: (userId, deed) -> deed.author_id is userId
#     update: (userId, deed) -> deed.author_id is userId or Roles.userIsInRole(userId, 'admin')
#     remove: (userId, deed) -> deed.author_id is userId or Roles.userIsInRole(userId, 'admin')

# Tribes.allow
#     insert: (userId, tribe) -> tribe.author_id is userId
#     update: (userId, tribe) -> tribe.author_id is userId or Roles.userIsInRole(userId, 'admin')
#     remove: (userId, tribe) -> tribe.author_id is userId or Roles.userIsInRole(userId, 'admin')




Meteor.publish 'tribes', (selected_tags, filter)->

    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # match.tags = $all: selected_tags
    
    if filter then match.type = filter

    Tribes.find match,
        limit: 5
        
        
Meteor.publish 'tribe_members', (tribe_id)->
    tribe = Tribes.findOne tribe_id
    Meteor.users.find
        _id: $in: tribe.members
        

Meteor.publish 'deed', (id)->
    Deeds.find id
    
    
Meteor.publish 'tribe', (id)->
    Tribes.find id
    
    
    
Meteor.publish 'deed_tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    deed_cloud = Deeds.aggregate [
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

    deed_cloud.forEach (deed_tag, i) ->
        self.added 'deed_tags', Random.id(),
            name: deed_tag.name
            count: deed_tag.count
            index: i

    self.ready()

