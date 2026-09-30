<h1 align="center">Project Management Toolbox</h1>

<p align="center">Tools, settings, templates, and instructions for managing projects</p>


# What


## Features


# Why


# How


## Use

Process overview:

-   Capture everything out of your brain and into files
    -   todos
    -   events
    -   potentially useful thoughts
-   Curate what you've captured:
    -   make sure any deadlines are accounted for
    -   within each project, sort items into more / average / less valuable
    -   check for dependencies for items that are valuable or have deadlines
    -   sort any independent items into more / average / less effort required
-   Monitor what is going on

Tools overview:

-   org capture templates help capture and organize different kinds of items
-   agenda views help curate items, successively narrowing down items we need to look at


### Details

-   Capturing Items

    -   Data Captured
    
        | Name                 | Meaning                              | Allowed Values                 | Notes                            |
        |-------------------- |------------------------------------ |------------------------------ |-------------------------------- |
        | Title                | Name of item                         | text                           | org-mode standard                |
        | CATEGORY             | Project the item belongs to          | project names                  | agenda standard                  |
        | FREQUENCY            | How often does this happen?          | once / repetitive / continuous |                                  |
        | HARD\_DATE           | Is there a date we must know about?  | yes / no                       |                                  |
        | INTERNAL\_DEPENDENCY | Must we do something else first?     | yes / no                       |                                  |
        | EXTERNAL\_DEPENDENCY | Must we wait on someone else first?  | yes / no                       |                                  |
        | TACTICAL\_VALUE      | How valuable is finishing this now?  | more / average / less          | relative to other project items  |
        | ESTIMATED\_EFFORT    | How much of our effort will it take? | less / average / more          | relative to all our current work |
        | TIMESTAMP            | When does this happen?               | date + time                    | org-mode standard                |
        | SCHEDULED            | When do we plan on doing this?       | date + time                    | org-mode standard                |
        | DEADLINE             | When is this due?                    | date + time                    | org-mode standard                |
    
    -   Capture Types
    
        | Name               | Meaning                            | FREQUENCY  | HARD\_DATE | Notes                                   |
        |------------------ |---------------------------------- |---------- |---------- |--------------------------------------- |
        | Task               | work you do                        | once       | no         |                                         |
        | Imminent Task      | Task to be done now                | once       | no         | tactical value = more, todo state = now |
        | Time-bound Task    | Task with a HARD\_DATE             | once       | yes        |                                         |
        | Routine            | repetitive Task                    | repetitive | no         |                                         |
        | Time-bound Routine | Routine with a HARD\_DATE          | repetitive | yes        |                                         |
        | Practice           | continous Task                     | continuous | no         |                                         |
        | Occurrence         | something that just happens        | once       | yes        |                                         |
        | Recurrence         | repetitive Occurrence              | repetitive | yes        |                                         |
        | Reference          | potentially useful thought or link |            |            | only data captured is CATEGORY          |
        | Journal Entry      | text filed under today's date      |            |            | captured to project's journal.org       |

-   Curation

    -   Views
    
        | Name                     | Purpose                                 | Included                                                             | Excluded                                                                            | Notes                                                      |
        |------------------------ |--------------------------------------- |-------------------------------------------------------------------- |----------------------------------------------------------------------------------- |---------------------------------------------------------- |
        | Hard Date Check          | Make sure we know what items need dates | Items missing HARD\_DATE value                                       | Items with HARD\_DATE value                                                         | Ususally taken care of by capture template                 |
        | Missing Occurrence Dates | Fill in missing TIMESTAMPs              | Occurrences with HARD\_DATE = yes but no TIMESTAMP                   | non-Occurrences, Occurrences with TIMESTAMP                                         |                                                            |
        | Occurrence Dates         | Check Occurrence dates                  | Occurrences with TIMESTAMP                                           | non-Occurrences, Occurrences without TIMESTAMP                                      |                                                            |
        | Missing Deadlines        | Fill in missing DEADLINEs               | Tasks with HARD\_DATE = yes but no DEADLINE                          | non-Tasks, Tasks with DEADLINE                                                      |                                                            |
        | Deadlines                | Check DEADLINES                         | Tasks with DEADLINE                                                  | non-Tasks, Tasks without DEADLINE                                                   |                                                            |
        | Tactical Evaluation      | Appraise relative Task value            | Tasks with no DEADLINE or a DEADLINE <= 1 month                      | non-Tasks, Tasks with DEADLINE > 1 month                                            |                                                            |
        | Relevant Dependencies    | Note existing dependencies              | More valuable or DEADLINE <= 1 month or todo state = next / now      | non-Tasks, Tasks with DEADLINE > 1 month, Tasks with less or average value          | Only track dependencies for the most important tasks       |
        | Effort Estimation        | Estimate relative Task effort           | More / average value, DEADLINE <= 1 month or todo state = next / now | non-Tasks, Tasks with dependencies, Tasks with less value                           | Allows us to catch Tasks with average value but low effort |
        | Soft Scheduling          | Tentatively schedule work               | HARD\_DATE = no, Tasks with more value or less effort                | non-Tasks, Tasks with dependencies, Tasks with less value or more effort than value |                                                            |
        | Task Activity            | Update what is happening day-to-day     | DEADLINE or SCHEDULED <= 1 week, or more value / less effort         | non-Tasks, Tasks with dependencies, Tasks with less value or more effort than value |                                                            |
        
        views: hard date check: make sure we know everything that needs a date attached missing occurrence/task dates: for everything that has a hard date, make sure we know the actual date

-   Troubleshooting

-   License
