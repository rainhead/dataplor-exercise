## Assignment

We have an adjacency list that creates a tree of nodes where a child's parent_id = a parent's id. I have provided some sample data in the attached csv.

Please make an api (rails, sinatra, cuba--your choice) that has two endpoints:

1) `/common_ancestor` - It should take two params, a and b, and it should return the root_id, lowest_common_ancestor_id, and depth of tree of the lowest common ancestor that those two node ids share.

For example, given the data for nodes:
```
id    | parent_id
---------+-----------
125 |       130
130 |          
2820230 |       125
4430546 |       125
5497637 |   4430546
```

`/common_ancestor?a=5497637&b=2820230` should return
`{root_id: 130, lowest_common_ancestor: 125, depth: 2}`

`/common_ancestor?a=5497637&b=130` should return
`{root_id: 130, lowest_common_ancestor: 130, depth: 1}`

`/common_ancestor?a=5497637&b=4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

if there is no common node match, return `null` for all fields

`/common_ancestor?a=9&b=4430546` should return
`{root_id: null, lowest_common_ancestor: null, depth: null}`

if `a==b`, it should return itself

`/common_ancestor?a=4430546&b=4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`


2) `/birds` - The second requirement for this project involves considering a second model, birds. Nodes have_many birds and birds belong_to nodes. Our second endpoint should take an array of node ids and return the ids of the birds that belong to one of those nodes or any descendant nodes.

The most efficient way to solve this problem probably involves pre-processing the data and then serving that pre-processed data, but I would like you assume that a different process will add to the data (with no assumption as to the magnitude of the additions). Your solution should be optimized for a system that could expand to hundreds of millions of records or maybe even billions of nodes.

At dataPlor we write software that deals with exponentially expanding data. We are looking for people who can take novel problems, demonstrate first principles design and performance that flows from deep understanding, and integrate that into best practices code quality and organization.


## Solution

```
\copy nodes from 'nodes.csv' with (format csv, header true);
\copy birds from 'birds.csv' with (format csv, header true);
```

- http://localhost:3000/common_ancestor?a=2168933&b=2168965
- http://localhost:3000/birds?node_ids=2169160

Finding the lowest common ancestor of two nodes involves comparing their ancestries. We build up the list of each node's ancestors by starting with it, and recursively adding its parent, its parent's parent, and so on, until we find a root. The lowest common ancestor is the first-found of the nodes appearing in both ancestry lists, and the common root is the last to be found. If the ancestry lists have no nodes in common, they are not part of the same connected graph.

Because the ancestry of a node may be very large, it would be much more efficient to perform as much work as possible, and the recursive loop especially, within the database itself. Doing so in Ruby would add network latency at each recursive operation, and require unbounded memory.

PostgreSQL provides recursive common table expressions (CTEs) as a means of performing recursive operations within a single query. We create a CTE for the ancestry of each input node, then join them together to find the nodes' common ancestry. By keeping track of our recursion depth, we can distinguish the highest and lowest common ancestors.


### Discussion

As a business' data expands in volume and complexity, it becomes more important to rely on the features and strictures of a database management system. SQL features like views and data constraints are not just convenient but necessary for the business to keep costs down and revenues up.

Using those features goes against the grain of ActiveRecord, which exposes only a small, portable subset of them. Adopting a library to ease their integration with Rails would go against the spirit of the exercise.

My main concern here is for the maintainability of the code. Inlined SQL literals are concise and fit to purpose, but harder to reuse and compose and easier to accidentally break than ActiveRecord scopes.

Separately, as a matter of organization, I made `Node.common_ancestor` a class method on Node. In Rails, there is a strong tendency to shove a kitchen sink of responsibility into model classes, which quickly become hard to maintain. The bundle of data exposed by `/common_ancestor` is properly its own model which deserves to be formalized. With additional use cases or business requirements, it may be clearer exactly what is being modeled and what to call it.

### Notes

- root nodes have a depth of 1, not 0
- the `lowest_common_ancestor` field does not have an `_id`
- a sample CSV of nodes was provided, but without corresponding tests, I wasn't sure what to do with it
