## ----, echo = FALSE------------------------------------------------------
DiagrammeR::mermaid('graph LR
field -->|...| field
field -->|,| delim

delim -->|...| field
delim -->|,| delim
delim -->|"| string
style delim fill:lightgreen

string -->|"| quote
string -->|...| string

quote -->|"| string
quote -->|,| delim
')

## ----, echo = FALSE------------------------------------------------------
DiagrammeR::mermaid('graph LR
escape_s --> string

string -->|\\| escape_s
string -->|...| string
string -->|"| string_complete
  
string_complete --> delim

delim -->|...| field
delim -->|,| delim
delim -->|"| string
delim -->|\\| escape_f
style delim fill:lightgreen

field -->|...| field
field -->|,| delim
field -->|\\| escape_f

escape_f --> field
')

