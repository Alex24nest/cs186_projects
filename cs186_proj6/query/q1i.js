// Task 1i

db.keywords.aggregate([
    // TODO: Write your query here
    {
        $match: {
            keywords: {
                $elemMatch: {
                    $or: [
                        { name: "mickey mouse" },
                        { name: "marvel comic" }
                    ]
                }
            }
        }
    },
    {
        $project: {
            _id: 0,
            movieId: 1
        }
    },
    {
        $sort: {movieId: 1}
    }
]);