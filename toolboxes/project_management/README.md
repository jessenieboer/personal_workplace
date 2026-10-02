<h1 align="center">Project Management Toolbox</h1>

<p align="center">Tools, settings, templates, and instructions for managing projects</p>


# What


## Features


# Why


# How


## Requirements

must have this in emacs config for agenda to work

```emacs-lisp
(add-hook 'org-agenda-mode-hook 'hack-dir-local-variables-non-file-buffer)
```


## Installation

Add devenv.yaml and devenv.nix to project root:

```yaml
inputs:
  personal_workplace:
    flake: false
    url: github:jessenieboer/personal_workplace/jn

imports:
  - personal_workplace/toolboxes/project_management
```

```nix
{ pkgs, lib, config, inputs, ... }:
let
  pmDir = "/.toolboxes/project_management_toolbox";
in
{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox = {
    project_name = "my_project_name";
    project_benefit = "The benefit this project aims at";
    subproject_agenda_files = [
      "${config.devenv.root}/sub1/${pmDir}/sub1.org"
      "${config.devenv.root}/sub2/${pmDir}/sub2.org"
    ];
    workers = [
      { name = "myname"; email = "myemail@email.com"; } # 
      { name = "anothername"; }
    ];
  };
}
```

Then in a shell in that directory

```shelld
devenv update
```


## Use

-   Capture everything out of your brain and into files
    -   todos
    -   events
    -   potentially useful thoughts
-   Prioritize what you've captured:
    -   make sure any deadlines are accounted for
    -   within each project, sort items into more / average / less valuable
    -   check for dependencies for items that are valuable or have deadlines
    -   sort any independent items into more / average / less effort required
-   Actually do stuff
-   Curate: keep everything up to date


### Details

Each item (except references) has one of 4 org todo states:

| State  | Meaning                |
|------ |---------------------- |
| future | This will happen later |
| next   | This will happen soon  |
| now    | This is happening now  |
| past   | This happened          |

-   Capture

    Get everything out of your head. Use capture templates when you are able to capture the right data and put your items in the right place. Otherwise, put freeform text into <project name>\_inbox.org for later processing.
    
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
        | CAPTURED\_BY         | Who captured this?                   | Worker defined in devenv.nix   |                                  |
    
    -   Capture Templates
    
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

-   Prioritize

    Date and evaluate items, using views, to make sure you're working efficiently on the most important stuff.
    
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

-   Do

    Actually do stuff.
    
    -   Views
    
        | Name     | Purpose                                         | Included                    | Excluded        | Notes |
        |-------- |----------------------------------------------- |--------------------------- |--------------- |----- |
        | Focus    | Only look at what we've prioritized for the day | Tasks with todo state = now | Everything else |       |
        | Calendar | Show scheduled items                            | Anything with a date        |                 |       |
    
    -   Practices
    
        -   put away project management stuff and just use the phone app when doing stuff
        -   when something out-of-current-scope comes up, capture and continue

-   Curate

    Keep everything up to date
    
    -   Views
    
        | Name       | Purpose                     | Included                        | Excluded        | Notes |
        |---------- |--------------------------- |------------------------------- |--------------- |----- |
        | Past Items | Archive items that are done | Anything with todo state = past | Everything else |       |
    
    -   Practices
    
        Daily curation:
        
        -   clear out inboxes
        -   Activity: change done items to "past" and choose items for "now"
        
        Periodic curation:
        
        -   Past Items
        -   Hard Dates Check
        -   Missing Dates and Missing Deadlines
        -   Tactical Evaluation (per project)
        -   Relevant Dependencies
        -   Effort Estimation
        -   Soft Scheduling (if necessary)

-   Instructions for AI

    -   When you capture an item, make sure you use one of the org-capture-templates defined in .dir-locals, naming yourself in the CAPTURED\_BY property and marking REVIEWED as no. If you are not defined as a worker in devenv.nix, you cannot capture.
    -   On request, capture items from the content in <project\_name>\_inbox.org
    -   Each day, for items that have TIMESTAMP, SCHEDULED, or DEADLINE due today, change the todo state to now. Any that are due within a week (but not today), change to next.

-   License
