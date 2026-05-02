// Task 2ii

db.movies_metadata.aggregate([
    // TODO: Write your query here
    {
        $project: {
            split: {
                $split: ["$tagline", " "]
            }
        }
    },
    {
        $unwind: "$split"
    },
    {
        $project: {
            _id: {$trim: {input: {$toLower: "$split"}, chars: ".,?!"}},
        }
    },
    {
        $project: {
            _id: 1,
            len: { $strLenCP: "$_id" },
        }
    },
    {
        $match: {len: {$gt: 3}}
    },
    {
        $group: {
            _id: "$_id",
            count: {$sum: 1}
        }
    },
    {$sort: {count: -1}},
    {$limit: 20}
]);