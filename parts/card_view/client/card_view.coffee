Template.card_view.events
    'click .deed_tag': ->
        if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
        
Template.card_view.helpers
    deed_tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
