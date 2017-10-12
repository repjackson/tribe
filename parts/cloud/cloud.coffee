@Tags = new Meteor.Collection 'tags'

if Meteor.isClient
    @selected_tags = new ReactiveArray []
    
    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags', selected_tags.array(), Template.currentData().filter)
    
    Template.cloud.helpers
        all_tags: ->
            # deed_count = Deeds.find().count()
            # if 0 < deed_count < 3 then Tags.find { count: $lt: deed_count } else Tags.find()
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
    
    
    Template.cloud.events
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
                        
        'autocompleteselect #search': (event, template, deed) ->
            # console.log 'selected ', deed
            selected_tags.push deed.name
            $('#search').val ''

        # 'click #add': ->
        #     Meteor.call 'add', (err,id)->
        #         FlowRouter.go "/edit/#{id}"
