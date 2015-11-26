angular.module('agileMetrics').factory 'elasticsearch', ($http) ->
    elasticObject =
        post: (config) ->
            @query 'POST', config
        query: (method, config) ->
            properties =
                method: method.toUpperCase()
                url: config.url
                data: config.query
            $http properties
        delete: (url) ->
            properties =
                method: 'DELETE'
                url: url
            $http properties

    elasticObject