Sqlite = require 'sqlite3'
Interface = require 'chocolate/general/locco/interface'

db = null

request =
    columns: {}

    columns_list: (callback) -> 
        db.all "pragma table_info(census_learn_sql)", callback
    
    one_column: (column, callback) ->
        get_stmt = (column, callback) ->
            return callback? request.columns[column] if request.columns[column]?
            
            request.columns_list (err, columns) ->
                prepared = 0
                for {name} in columns then do (name) ->
                    stmt = db.prepare "select \"#{name}\" as value, count(*) as count, round(avg(age),1) as avg from census_learn_sql group by \"#{name}\" order by \"#{name}\" desc", ->
                        request.columns[name] = stmt
                        if ++prepared is columns.length then callback? request.columns[column]
    
        get_stmt column, (stmt) -> stmt.all callback

    non_displayed: (column, lines, callback) ->
        values = ('"' + line.value + '"' for line, i in lines when i < 100)
        db.get "select count(*) as value from census_learn_sql where \"#{column}\" not in (#{values.join(',')})", callback

main = new Interface.Web.Html
    steps: ->
        db ?= new Sqlite.Database "#{@props.__.datadir}/us-census.db", -> process.on 'exit', -> db.close()
        request.columns_list (err, columns) => @props.columns = columns.sort((c1, c2) -> if c1.name > c2.name then 1 else -1) ; @respond()
        @respond.later

    render: ->
        html -> body ->
            link rel:"stylesheet", href:"https://cdn.jsdelivr.net/npm/semantic-ui@2.2.13/dist/semantic.min.css"
            script src:"https://cdn.jsdelivr.net/npm/jquery@2.2.4/dist/jquery.min.js"
            script src:"https://cdn.jsdelivr.net/npm/semantic-ui@2.2.13/dist/semantic.min.js"
            
            div '.ui.container', ->
                h1 "Census data"
                label "Variable: "
                select '#column.ui.dropdown', ->
                    option field.name for field in @props.columns
                
                table '#result.ui.celled.table', ->
                
            coffeescript ->
                $ ->
                    query_column = -> $.get '', {query_column:'', column:$('#column').val()}, (result) -> $('#result').html result
                        
                    $('#column').dropdown action: 'activate', onChange: -> query_column()
                    
                    query_column()
                        

query_column = new Interface.Web.Html
    steps: ->
        request.one_column @props.column, (err, lines) => 
            @props.lines = lines
            if lines.length > 100
                request.non_displayed @props.column, lines, (err, count) => 
                    @props.non_displayed_lines = count.value
                    @respond()
            else 
                @respond()
        @respond.later

    render: ->
        thead ->
            tr -> th 'value' ; th 'count' ; th 'average age'
        
        if @props.lines.length > 100
            tr -> td colspan:3, "Only 100 values out of #{@props.lines.length} are displayed"
            tr -> td colspan:3, "Non displayed values represent #{@props.non_displayed_lines} line#{if @.props.non_displayed_lines > 1 then 's' else ''} in database"

        for line, i in @props.lines when i < 100
            tr ->
                td line.value ; td line.count ; td line.avg
    

module.exports = {'interface': main, query_column}