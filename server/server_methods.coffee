Meteor.methods
    join_tribe: (tribe_id)->
        Tribes.update tribe_id,
            $addToSet: members: Meteor.userId()

    leave_tribe: (tribe_id)->
        Tribes.update tribe_id,
            $pull: members: Meteor.userId()
