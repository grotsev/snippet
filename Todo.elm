import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)

type alias State = 
  { title : Maybe String
  , newTodo : String
  , todos: List String
  }

// actions
type Msg
  = Edit String
  | Add

init =
  { title = Nothing
  , newTodo = ""
  , todos = []
  }

// render
view state =
  div []
    [ label [] [ text <| Maybe.withDefault "Без названия" state.title ]
    , div []
      [ input
        [ value state.newTodo
        , placeholder "Название задачи"
        , onInput Edit
        ] []
      , button [ onClick Add ] [ text "Добавить" ]
      , ul [] <| List.map ( \todo -> li [] [ text todo ] ) state.todos
      ]
    ]

// reducer
update msg state =
  case msg of
    Edit newTodo ->
      { state | newTodo = newTodo }
    
    Add ->
      { state | newTodo = "", todos = state.newTodo :: state.todos}

main = beginnerProgram { model = init, view = view, update = update }
