

Stakeholders

1. Application Developers(AppDev) - Application developers build application that use a mix of IC tech and traditional tech to build apps for their customers.
2. Dependent Application Developers(DepDev) - Dependent application developers build applications that use a mix of IC tech and traditional tech to build apps and their apps depend on the behaviors of other apps in the IC ecosystem.
3. nISP token users(nISP User) - nISP token users have to own nISP tokens to utilize services overed by dRoute.  They stake tokens to receive preferential notifications of events on the dRoute network.
4. nISP governor(Governor) - a nISP token governor makes decisions to benefit the network. As the network grows in importance they receive a larger payment for their work of governing the network.
5. App user(App User) - an app user uses a service that implements dRoute.
6. dRoute(Service) - the dRoute system.

Form Language

Application - An computer program that seeks to accomplish some type of work.
Event - an event is raised by an application and represents the occurrence of a particular computation on that application. It includes the event identifier and event metadata
Event Identifier - represents a particular type of event
Event Metadata - represents instance specific data about an event.
Encrypted Event - An Event that has been encrypted so that only certain users can decode it.
Event Subscription - A application can subscribe to an event an in order to have dRoute reserve the occurrence of that event for the subscribing application.
Event Notification Canisters - Canisters used to distribute notification and queue entries. Event Notification Canisters are owned by AppDevs.
Event Queue - An event queue will keep a running queue of events that can be handled at an applications leisure.  Event Queue canisters are owned by DepDevs.
Event Notification - A event that is delivered directly to a subscribing application.
Event Filter - A filter put in place to limit the types, kind, or content of events that are reserved for an event subscription.

Pattern Language

Self Directed Management - AppDevs and DepDevs should be able to decide how their assigned canisters are manages/paid for.
Secure Data - The System should provides secure data so that outside observers cannot divine what is going on with the system from the outside.
Prompt Notification - The system should provide for prompt notification of events to be maximally useful.


User Stories

1. AA AppDev IWT notify other apps of events that have ocurred during the processing of my application STI increase the network effects of my application.


2. AA DepDev IWT subscribe to events of another app STI can trigger processing in my app based on that information.


3. AA DepDev User IWT stake my tokens in dRoute STI can get notification priority.


4. AA DepDev User IWT see where my stake ranks in relation to other dRoute stakers STI can make decisions about my stake.


5. AA DepDev User IWT have my stake be reliable and maintainable STI don't have to pay attention to it.


6. AA AppUser IWT never have to think about nISP or dRoute STI have a clean user experience.


7. AA Governor IWT support the use of dRoute STI get a larger payment.


8. AA DepDev IWT be assured that my events are delivered as fast as possible STI can respond in a timely manner.


9. AA DepDev IWT be assured that no messages are missed STI don't miss information.


10. AA DepDev IWT what I pay for message delivery to be predictable STI am not surprised by unexpected expenses.


11. AA AppDev ITW know who is using my event notifications STI can understand the importance of my application.


12. AA AppDev IWT encrypt my event information STI keep my users information safely.


13. AA AppDev IWT control who can subscribe to my events STI can monetize the information coming out of my system.


14. AA DepDev IWT easily pay for data subscriptions from AppDevs STI can easily integrate.


15. AA Governor IWT reward popular events STI incentivize use of the network.


16. AA DepDev IWT transparently receive encrypted data STI don't have to think about encryption.


17. AA Service IWT quickly return function calls STI can handle a large volume of calls.


18. AA Service IWT distribute my processing STI can handle a large volume of calls.


19. AA DepDev IWT have the option to have events pushed to me by dRoute STI can handle them automatically.


20. AA DepDev IWT have the option to have events queue up STI can handle them at my own pace.


21. AA DepDev IWT bto filter out events based on their metadata content STI don't get bombarded by events that I don't care about.


22. AA AppDev IWT keep track of my dRoute canisters STI can manage the cycles needed to run it.


23. AA AppDev IWT give access to my dRout canisters to someone else STI can have them manage the cycles in my canisters.


24. AA AppDev IWT recover the cost of notifying DepDevs of events from my dRout canisters STI can control expenses.



