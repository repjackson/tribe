@selected_tags = new ReactiveArray []


Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment
