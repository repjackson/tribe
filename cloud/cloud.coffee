@Tags = new Meteor.Collection 'tags'
@Author_ids = new Meteor.Collection 'author_ids'

if Meteor.isClient
    @selected_tags = new ReactiveArray []
    @selected_author_ids = new ReactiveArray []
    
    # Template.tag_cloud.onCreated ->
    
    Template.tag_cloud.helpers
        all_tags: ->
            # need_count = needs.find().count()
            # if 0 < need_count < 3 then Tags.find { count: $lt: need_count } else Tags.find()
            Tags.find()    
    
    
        tag_cloud_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class
    
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
                ]
        }
        
    
        selected_tags: -> 
            # type = 'event'
            # console.log "selected_#{type}_tags"
            selected_tags.array()
    
    
    Template.tag_cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
        
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tags.pop()
                        
        'autocompleteselect #search': (event, template, need) ->
            # console.log 'selected ', need
            selected_tags.push need.name
            $('#search').val ''

        # 'click #add': ->
        #     Meteor.call 'add', (err,id)->
        #         FlowRouter.go "/edit/#{id}"



    Template.username_cloud.onCreated ->
        # @autorun => 
        # @autorun -> Meteor.subscribe('tags', selected_tags.array(), selected_author_ids.array())
        # Meteor.subscribe 'usernames'
    
    
    
    Template.username_cloud.helpers
        author_tags: ->
            author_usernames = []
            
            for author_id in Author_ids.find().fetch()
                
                found_user = Meteor.users.findOne(author_id.text)
                # if found_user
                #     console.log Meteor.users.findOne(author_id.text).username
                author_usernames.push Meteor.users.findOne(author_id.text)
            author_usernames
    
    
        selected_author_ids: ->
            selected_author_usernames = []
            for selected_author_id in selected_author_ids.array()
                selected_author_usernames.push Meteor.users.findOne(selected_author_id).username
            selected_author_usernames
        
        
    Template.username_cloud.events
        'click .select_author': ->
            selected_author = Meteor.users.findOne username: @username
            selected_author_ids.push selected_author._id
        'click .unselect_author': -> 
            selected_author = Meteor.users.findOne username: @valueOf()
            selected_author_ids.remove selected_author._id
        'click #clear_authors': -> selected_author_ids.clear()

