1. completing a project by clicking on it, didn't update the UI in real time. I had to refresh 
2. Even though I clicked complete for website design alone, it completed for the other tabs as well. There's no isolation. clicking complete on one tab completes for the others as well. 
3. Reopen button also needs a refresh before the the state updates. 

Main issues: 
Component needs to re-render after it's clicked, the refresh with the permanent state change indicates the backend receives it but the frontend is not registering it. We need to find out two things: 
a. why the button title state does not automatically change when the user clicks on complete and re-open
b. why user actions on project, affects the others: the task.id's are not unique. 

Solutions: 
a. re-render the component after button is clicked: probablly not a re-render issue. 
b. get unique id numbers for task.id