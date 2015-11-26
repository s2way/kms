angular.module('agileMetrics').config (toastrConfig) ->
  angular.extend toastrConfig,
    autoDismiss: true,
    containerId: 'toast-container',
    maxOpened: 0,
    newestOnTop: true,
    positionClass: 'toast-top-center',
    preventDuplicates: false,
    preventOpenDuplicates: false,
    target: 'body'

angular.module('agileMetrics').controller 'usController', ($scope, elasticsearch, $interval, $filter, toastr, $cookies) ->
    indexPath = 'http://10.40.48.48:9200/kanban'
    $scope.selectedTeam = $cookies.get('team') or 'Newborns'
    $scope.teams =
        'Newborns':
            fields: [
                'todo'
                'developing'
                'totest'
                'testing'
                'readyfordeploy'
                'deploying'
                'done'
            ]
        'Old Skull':
            fields: [
                'needsrefinement'
                'todo'
                'developing'
                'totest'
                'undersystemtest'
                'readyfordeploy'
                'partiallydeployed'
                'done'
            ]
        'HardwÆrwolves':
            fields: []

    # não adicionar campos de data aqui, pois o format não busca neste array
    $scope.headers = [
        'id'
        'role'
        'estimated'
        'costumer'
        'release'
        'class'
    ]
    $scope.newTask = {}
    $scope.tasks = []
    $scope.roles =['US', 'BUG', 'REFACTORING', 'INFRA', 'SPIKE', 'TECHNICAL_DEBT', 'TIMED', 'FEATURE']
    $scope.classes =['DEFAULT', 'EXPEDITE', 'SELF-EXPIRING']
    $scope.labels =
        US: 'label label label-us'
        BUG: 'label label-bug'
        REFACTORING: 'label label-refactoring'
        INFRA: 'label label-infra'
        SPIKE: 'label label-spike'
        TECHNICAL_DEBIT: 'label label-technical_debit'
        TIMED: 'label label-timed'
        FEATURE: 'label label-feature'
    # finds all tasks of the selected team
    $scope.changeSelectedTeam = (selectedTeam) ->
        $cookies.put 'team', selectedTeam
        $scope.newTask = {}
        $scope.findTeamTasks selectedTeam

    $scope.findTeamTasks = (selectedTeam) ->
        findTasksConfig = 
            url: "#{indexPath}/#{selectedTeam.toLowerCase()}/_search"
            query:
                sort:
                    id: 'desc'
        elasticsearch.post(findTasksConfig)
            .success((response, statusCode) ->
                if response? and statusCode is 200
                    $scope.tasks = response.hits?.hits.map (item) ->
                        for field in $scope.teams[selectedTeam].fields
                            item._source[field] = $filter('date')(item._source[field], 'dd/MM/yy HH:mm')
                        return item
            ).error (msg) ->
                console.log msg

    $scope.createTask = (task) ->
        $scope.newTask = {}
        $scope.addTaskForm = false
        newTaskConfig =
            url: "#{indexPath}/#{$scope.selectedTeam.toLowerCase()}/#{task.role.toUpperCase()}#{task.id}"
            query: formatDatetimes task, $scope.selectedTeam
        elasticsearch.post(newTaskConfig)
            .success(->
                toastr.success 'Success'
                $scope.findTeamTasks $scope.selectedTeam
            ).error (msg) ->
                toastr.error msg, 'Error'
                $scope.findTeamTasks $scope.selectedTeam

    $scope.deleteTask = (id) ->
        deleteUrl = "#{indexPath}/#{$scope.selectedTeam.toLowerCase()}/#{id}"
        elasticsearch.delete(deleteUrl)
            .success(->
                toastr.success 'Success'
                $scope.findTeamTasks $scope.selectedTeam
            ).error (msg) ->
                toastr.error msg, 'Error'
                $scope.findTeamTasks $scope.selectedTeam

    $scope.editTask = (task) ->
        $scope.addTaskForm = true
        $scope.newTask = task

    $scope.close = ->
        $scope.addTaskForm = false
        $scope.newTask = {}

    $interval ->
        $scope.findTeamTasks $scope.selectedTeam
    , 1000

    $scope.findTeamTasks $scope.selectedTeam

    formatDatetimes = (task, team) ->
        for field in $scope.teams[team].fields
            task[field] = if moment(task[field], 'DD/MM/YY HH:mm').isValid() then moment(task[field], 'DD/MM/YY HH:mm').format() else null
        return task
