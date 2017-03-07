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


Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret



    


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
    insert: (userId, deed) -> deed.author_id is userId
    update: (userId, deed) -> deed.author_id is userId or Roles.userIsInRole(userId, 'admin')
    remove: (userId, deed) -> deed.author_id is userId or Roles.userIsInRole(userId, 'admin')




Meteor.publish 'deeds', (selected_tags, filter)->

    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # match.tags = $all: selected_tags
    
    if filter then match.type = filter

    Deeds.find match,
        limit: 5
        

Meteor.publish 'deed', (id)->
    Deeds.find id
    
    
    
Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    cloud = Deeds.aggregate [
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

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

