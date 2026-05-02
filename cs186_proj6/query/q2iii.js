// Task 2iii

db.movies_metadata.aggregate([
    // TODO: Write your query here
    {
        $project: {
            budget: {
                $cond: {
                    //if valid
                    if: {
                        $and:
                            [
                                {$ne: ["$budget", undefined]},
                                {$ne: ["$budget", false]},
                                {$ne: ["$budget", null]},
                                {$ne: ["$budget", ""]},
                            ]
                    },
                    then: {
                        //round to nearest ten mill
                        $round: [{
                                    $cond: {
                                        if: {$isNumber: "$budget"},
                                        then: "$budget",
                                        else: {
                                            $toInt: {
                                                $trim: {
                                                    input: "$budget",
                                                    chars: " USD\$"
                                                }
                                            }
                                        }

                                    }
                                }, -7
                        ]
                    },
                    //if undefined
                    else: "unknown"
                }
            }
        }
    },
    //group by budget
    {
        $group: {
            _id: "$budget",
            count: {$sum: 1}
        }
    },
    {$project: {_id: 0, budget: "$_id", count: 1}},
    {$sort: {budget: 1}}
]);