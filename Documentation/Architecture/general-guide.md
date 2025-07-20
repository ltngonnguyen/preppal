PrepPal: a Hyper-Localized Disaster Preparedness Application for Ho Chi Minh City
Report word count (excluding References and Title) so far: 4918 words.
1. Introduction (397 words)
The problem area I have chosen to focus on is the pressing need for innovative solutions to bolster community resilience against the rising impacts of climate change and the increasing frequency of urban disasters. To that end, I am proposing PrepPal, a hyper-localized mobile application designed to elevate disaster preparedness and response, tailored specifically for the residents of Ho Chi Minh City (HCMC), Vietnam. I believe that HCMC's distinct vulnerabilities, particularly its susceptibility to severe urban flooding and heat stress [2, 17], demand a focused strategy that the more generic, one-size-fits-all tools currently on the market often lack.
Therefore I have chosen 10.1 CM3050 Mobile Development Project Idea 1: Developing a Mobile App for Local Disaster Preparedness and Response as my response to this problem area.
While I will adhere to the core requirements of that template, such as implementing gamification and location-based alerts (which will be simulated for HCMC-specific scenarios), my attempt with PrepPal is to be both original and ambitious. It expands significantly on the foundational idea by emphasizing the cultivation of long-term preparedness habits, ensuring hyper-localization to HCMC's distinct environmental and cultural context, and integrating support for psychological well-being, a dimension largely ignored by current tools.
In the process of conceptualizing this project, I've also conducted an extensive literature review to assess the state of the art, examining both commercial disaster preparedness applications and relevant academic research to identify critical gaps that justify PrepPal's development. My investigation will explore several key themes:
The effectiveness of existing applications.
Strategies for long-term user engagement, including the use of gamification and persuasive technology.
The integration of psychological support to address climate anxiety.
The critical importance of offline functionality in a disaster scenario.
Technology's potential role in fostering genuine community resilience.
The overarching goal of this report is to demonstrate how PrepPal is strategically engineered to address these identified needs. I aim to contribute a valuable and contextually relevant tool for the HCMC community. In short, the application is intended to be accessible and useful for any individual residing in HCMC who owns a smartphone and wishes to become better prepared for emergencies specific to the city.
I believe this attempt is both novel and ambitious, and through this project, I hope to provide a comprehensive solution that, in the spirit of my favourite saying, proves to be "not just another model, but a useful one" [8].
2. Literature Review (1745 words)
2.1. Review of Existing Commercial Disaster Preparedness Applications
An examination of current commercial offerings, ranging from globally recognized platforms to more localized efforts, reveals that significant gaps remain. I believe these gaps are particularly apparent concerning deep localization, sustained user engagement, and a more holistic approach to user support.
2.1.1. FEMA App (USA)
The FEMA App, developed by the U.S. Federal Emergency Management Agency, stands as a prominent example of a government-backed disaster preparedness tool [4]. Its stated aim is to provide a comprehensive resource for the American public, covering the planning, protection, and recovery phases of a disaster.
Key Features (from [4, 5]):
Real-time weather and emergency alerts from the National Weather Service (NWS) and the Integrated Public Alert and Warning System (IPAWS) for user-specified locations.
Guidance on creating family emergency plans and assembling preparedness kits.
Locators for finding nearby shelters and information on accessing FEMA assistance.
Inclusion of accessibility features.
Strengths: As an official government application, it serves as an authoritative and, presumably, reliable source of information. The ability to monitor alerts for multiple locations and the focus on accessibility are also notable strengths.
Limitations and Relevance to PrepPal: The primary limitation of the FEMA app for a global audience, and specifically for a project targeting Ho Chi Minh City, is its inherent US-centricity. Its data sources, such as the NWS and IPAWS, and its assistance information are only relevant to residents of the United States [4]. More critically, user feedback often points to issues like "alert fatigue," stemming from what users perceive as irrelevant or duplicate notifications, even with location precision [4, 6]. From my perspective, this highlights a significant challenge: technical accuracy in alerting is insufficient if it doesn't account for user perception and context. Furthermore, the application appears to be lacking in robust features designed for proactive, ongoing engagement, such as detailed stockpile management or dedicated support for climate-related anxiety. I find that this underscores a significant opportunity for an application like PrepPal. A new approach could provide a solution that is not only hyper-localized to the specific risks of HCMC (e.g., urban flooding, heat stress) but is also fundamentally designed to foster sustained user engagement and support psychological well-being.
2.1.2. "Vietnam Disaster Prevention" Zalo Mini-App (Vietnam)
A more locally relevant example is the "Vietnam Disaster Prevention" Mini-App, which is integrated within the popular Zalo messaging platform in Vietnam. This initiative represents a collaboration between Vietnam's National Steering Committee for Natural Disaster Prevention and Control and UNICEF [11].
Key Features (from [11, 16]):
A "Relief Connectivity" function for users to request aid.
An "Emergency Contact" list for quick communication.
A "Disaster Report" function allowing users to submit information from the scene.
A knowledge section covering various disaster types and appropriate responses, which is notably available in several ethnic minority languages.
Leverages the Zalo platform to disseminate urgent alerts.
Strengths: Its integration within a ubiquitous platform like Zalo provides a massive potential reach and significantly lowers barriers to adoption [16]. Furthermore, the official government backing lends it a high degree of credibility, and I find the inclusion of multilingual support to be a significant and commendable step towards inclusivity.
Limitations and Relevance to PrepPal: While this is a laudable effort, especially for its reach and response-oriented features, my analysis suggests the Zalo Mini-App is primarily focused on the immediate aftermath of disasters, with functions geared toward relief and reporting. There appears to be less emphasis on cultivating proactive, long-term preparedness habits. I see a lack of features such as interactive planning tools, skill-building modules, or sophisticated stockpile management systems. As a "mini-app," it might also face inherent limitations in UI complexity and, crucially, offline functionality when compared to a dedicated native application. This presents a clear niche for PrepPal. The project can serve as a complementary tool, designed specifically to build and maintain long-term preparedness within HCMC's unique urban context, moving beyond simple information dissemination toward active and sustained user engagement in readiness.
2.3. Review of Relevant Academic Research & Methodologies
Academic research offers a critical foundation for designing effective disaster preparedness tools, especially when considering user engagement, behavior change, and the multifaceted impacts of these events.
2.3.1. Gamification for Sustained Engagement
Gamification, which involves integrating game-design elements into non-game contexts, is an approach that has been widely explored for its potential to improve user motivation and learning in domains like disaster preparedness.
Key Research Findings: I've found that systematic reviews confirm that gamification can enhance initial user motivation, participation, and knowledge acquisition [9]. Elements such as points, badges, and leaderboards are commonly employed.
Limitations of Current Gamification Approaches: However, a significant challenge, as noted by Johnson et al. [9], is the difficulty in achieving sustained, long-term engagement. The novelty can diminish over time, and I believe that poorly designed gamification can become ineffective or even demotivating. Many existing studies also lack methodological rigor or fail to base their designs on established behavior change theories.
Implications for PrepPal: These findings are crucial for the development of PrepPal. It is my belief that simply incorporating superficial game elements is an inherently lazy approach and will not foster the long-term habit formation required for disaster preparedness. Instead, PrepPal must utilize a more sophisticated, theory-driven gamification strategy. This means I will focus on individual motivation by addressing users' needs for personal growth (e.g., mastering preparedness skills), autonomy through personalized goals, and relatedness via community challenges specifically relevant to Ho Chi Minh City. My objective is the internalization of preparedness behaviors, not mere short-term task completion.
2.3.2. Persuasive Technology for Behavior Change
Persuasive Technology (PT) offers valuable frameworks and strategies for positively influencing user attitudes and behaviors, a goal that is highly relevant for encouraging proactive preparedness.
Core Principles and Strategies: The Persuasive System Design (PSD) model presents a structured approach, categorizing strategies such as personalization, self-monitoring, reminders, simplification (reduction), and establishing credibility [15]. Research confirms that user acceptance of disaster-related applications is strongly correlated with their perceived usefulness, ease of use, and trust in the source of information [1].
User Needs in Disaster Apps: Existing research underscores that users place a high value on receiving reliable and timely alerts, clear evacuation information, and trustworthy guidance [1, 13].
Implications for PrepPal: PrepPal's design will be explicitly guided by PT principles. Building and maintaining user trust is paramount. This requires transparency, reliability, and credible, HCMC-specific information. Key strategies will include personalization, such as risk assessments for different HCMC districts and tailored checklists; self-monitoring, for tracking supply inventories and completed tasks; and reduction, which involves simplifying complex actions into more manageable steps.
2.3.3. Addressing Climate Anxiety through Digital Tools
The psychological impact of climate change and disaster risk, frequently described as "climate anxiety," is an increasingly significant concern. Digital tools are now emerging as a potential avenue for providing support.
The Rise of Climate Anxiety and Need for Support: There is a growing acknowledgment of the mental health effects, including anxiety, grief, and trauma, that are linked to climate change and disasters [3].
Potential of Digital Interventions: Research is currently exploring how mobile apps and other digital platforms can offer psychoeducation, coping strategies, and scalable mental health interventions to address these issues [3, 12].
Implications for PrepPal: From what I can observe, current disaster applications largely overlook this dimension. This gives PrepPal a novel opportunity to be innovative by integrating features designed to help HCMC users manage climate anxiety. My approach would involve providing curated resources, evidence-based coping techniques like mindfulness exercises, and framing preparedness actions in a positive, empowering manner to support both physical safety and mental resilience.
2.3.4. Offline Functionality and Community Resilience Technologies
During a disaster, reliable access to information and effective community coordination are vital, particularly when conventional infrastructure is compromised.
Critical Need for Offline Access: Disasters often lead to disruptions in communication networks, which makes offline access to essential information and tools a necessity rather than a luxury [10, 14].
Role of Technology in Fostering Community Coordination: Technology can be leveraged to facilitate improved communication, information sharing, and mutual aid among residents and local organizations, thereby enhancing overall community resilience [7].
Implications for PrepPal: It is imperative that PrepPal prioritizes robust offline functionality for its core features, including checklists, HCMC-specific guidance, user inventory data, and emergency contacts. Furthermore, there is significant potential to develop features that foster preparedness at the community level within HCMC neighborhoods, such as localized information sharing or tools for coordinating mutual aid, moving beyond the basic reporting functions seen in other applications.
2.4. Synthesis and Identified Gaps for PrepPal
This review of commercial applications and academic literature reveals several critical gaps that my project, PrepPal, is specifically designed to address, particularly within the HCMC context:
Lack of Hyper-Local Context: Global applications like FEMA's are not tailored to the specific climate risks of HCMC, such as its diverse flooding types and heat stress, nor do they account for local infrastructure or cultural nuances. Even national applications like the Zalo Mini-App, while valuable for their broad reach, may not provide the granular, neighborhood-level preparedness guidance that HCMC requires. PrepPal will prioritize this hyper-localization.
Deficiency in Long-Term Preparedness Support: From what I can observe, most current applications focus on initial planning or immediate response. There is a significant unmet need for tools that support the ongoing management of preparedness, such as detailed stockpile tracking with expiry alerts, reminders for skill maintenance, and adaptive guidance. PrepPal aims to fill this gap by fostering long-term preparedness habits.
Superficial or Ineffective Engagement Strategies: Many applications struggle with sustained user engagement, often due to issues like alert fatigue, as seen with the FEMA app, or the use of simplistic gamification that fails to maintain motivation over the long term [9]. It is my belief that this project must leverage deeper, theory-driven persuasive technology and meaningful gamification to cultivate intrinsic motivation and lasting behavior change.
Neglect of Psychological Well-being: The mental health dimension of disaster preparedness, especially climate anxiety, is almost entirely unaddressed by current applications. PrepPal sees an opportunity to be innovative in this area by integrating support features, thereby becoming a more holistic resilience tool.
Inconsistent Offline Functionality and Underdeveloped Community Features: While the necessity of offline access is acknowledged in research [14], its implementation is often limited. Similarly, I find that tools for proactive, community-level coordination and mutual aid remain underdeveloped [7]. My approach with PrepPal is to ensure core features are robustly offline and to explore innovative methods for enhancing community resilience within HCMC.
3. Design (1999 words)
3.1 Overview
PrepPal is an application I have conceived to enhance disaster preparedness and community resilience, with a focus on the unique challenges faced by residents of HCMC. The project's objective is to address the gaps I have identified in current disaster preparedness applications by delivering a hyper-localized, engaging, and comprehensive tool. Its key features are designed as direct solutions to these shortcomings, including: HCMC-specific risk information, interactive emergency kit management with meaningful gamified elements [9], support for psychological well-being [3, 12], access to local community resources [7], and robust offline functionality [10, 14].
This project is grounded in the 10.1 CM3050 Mobile Development Project Idea 1: Developing a Mobile App for Local Disaster Preparedness and Response. 
3.2 Domain and Users
Domain: The project is within the domain of mobile application development for public safety and personal well-being, with a specialized focus on disaster preparedness and community resilience in a dense urban environment. It intersects with several key fields, including information dissemination, education, behavioral science, and mental health support. All these facets will be tailored to the specific environmental challenges, such as urban flooding and heat stress [2, 17], and the unique socio-cultural landscape of HCMC.


Users: The primary users of PrepPal are the residents of HCMC. I have identified the following user groups:


Individuals and Families: Those seeking to improve their personal and household preparedness for disasters relevant to their locality.
Diverse Demographics: While the application aims for broad appeal, I will make practical considerations for varying levels of technological proficiency and access. Crucially, language support will be provided, with Vietnamese as the primary language.
Community Members: Users who can benefit from localized information regarding emergency services, shelters, and curated advice. Although user-generated content moderation is outside the initial scope of this project, the inclusion of officially-sourced or community-vetted preparedness tips is planned.
3.3 Justification of Design Choices
Hyper-Localization (HCMC Focus):
Need: Generic disaster applications lack the granular detail required for HCMC, failing to address its unique risks, local alert systems, evacuation routes, and cultural context [2, 17].
Design Choice: The application will therefore feature dedicated sections for HCMC-specific risk information. This includes interactive maps that highlight vulnerable areas, and guidance tailored to local scenarios. All content will be culturally appropriate and provided primarily in Vietnamese.
Justification: This approach enhances the relevance and provides actionable insights for HCMC users, increasing the application's practical value and utility.
Long-Term Preparedness & Tracking:
Need: I have observed that many applications focus on one-time planning. However, sustained preparedness is an ongoing effort that requires continuous management.
Design Choice: Consequently, features for detailed stockpile management and a personalized emergency plan builder are central to my design. Gamification targets those specific areas.
Justification: This strategy promotes the development and maintenance of preparedness habits over time, beyond the superficiality of a initial setup.
Engaging User Experience (Gamification & UI/UX):
Need: As my research indicates, sustained user engagement is a major challenge for preparedness applications, with many suffering from alert fatigue or ineffective gamification [9].
Design Choice: I will implement a "Calm Resilience" visual theme, creating a supportive, non-alarming user interface. The gamification strategy is central to fostering sustained engagement and will be deeply integrated, moving beyond superficial elements. Specific features include:
Tiered Achievement System: Progress bars will track overall preparedness, while a multi-tiered system of achievement badges and certificates will reward the completion of specific preparedness categories and milestones within core tasks like stockpile management and emergency plan creation.
Personalized "Resilience Quests": Users will be offered tailored mini-tasks or "quests" based on their current progress and HCMC-specific risks. Completing quests earns points and contributes to unlocking further guidance.
Engagement Streaks & Gentle Nudges: Daily or weekly check-ins, or completion of small preparedness actions like reviewing a safety tip, will build "Preparedness Streaks," visually represented to encourage consistency. Gentle, positively-framed reminders will nudge users towards maintaining their streaks or addressing overdue tasks, avoiding alarmist notifications.
Unlockable Content & Customization: Points earned can unlock advanced HCMC-specific preparedness guides, inspiring local resilience stories, or minor cosmetic customizations within the "Calm Resilience" theme, providing intrinsic rewards for continued learning and engagement.
The application's navigation will be intuitive, guided by a clear information architecture (see Section 3.4.1).
Justification: This design encourages continued use and interaction, making the often-daunting task of disaster preparedness more approachable and rewarding for the user.
Psychological Well-being (Climate Anxiety Support):
Need: The mental health impact of climate change and disaster risk is a dimension that is often overlooked in existing tools, despite growing recognition of its importance [3, 12].
Design Choice: A dedicated section will provide users with curated resources, simple coping strategies, and will link well-being with actionable preparedness steps to empower users.
Justification: My intent is to offer holistic support, acknowledging the emotional toll of disaster awareness and empowering users to manage it constructively.
Robust Offline Functionality:
Need: During a disaster, communication networks are frequently disrupted, making online-only tools unreliable and offline access a necessity [10, 14].
Design Choice: Core interactive features will be stored locally. I will utilize sqflite, with data initially sourced from a Firebase backend or bundled with the application.
Justification: This ensures that critical information and tools are accessible to users when they are needed most, irrespective of internet connectivity.
Community Resources (HCMC Specific):
Need: There is a clear need for quick and reliable access to verified local support systems during emergencies to improve community resilience [7].
Design Choice: The application will include a curated directory of HCMC emergency services, official community shelters, and potentially admin-vetted preparedness tips sourced from local community knowledge or official advisories.
Justification: This provides reliable, localized information, which enhances community-level awareness and improves access to support networks.
Technology Stack (Flutter & Firebase)
Need: The project requires efficient cross-platform development, robust backend services, and presents an opportunity for me to learn a new skill and broaden my software engineering horizon.
Design Choice:
Flutter: This framework allows for rapid development for both iOS and Android from a single Dart codebase.
Firebase: I have chosen Firebase as it provides a scalable and easy-to-use backend solution, including Firestore (NoSQL database), Authentication, and Storage. It also integrates well with the Flutter frontend.
3.4 Overall Structure of the Project
3.4.1 Information Architecture & Visual Interface
Home/Dashboard: Overview of alert status, quick access to key preparedness tasks (e.g., "Check Stockpile," "Review Plan"), and navigation to other main sections.
Preparedness Hub (HCMC Focus):
HCMC Risk Information & Guidance (flooding, heat stress, etc., with interactive map elements).
Emergency Kit Checklists (gamified, HCMC-tailored).
Family Emergency Plan Builder (personalized, offline).
Stockpile Management: View, add, edit, and delete emergency supplies; track quantities and expiry dates with reminders.
Alerts: Display of (simulated for this project) HCMC-specific emergency alerts with actionable guidance.
Well-being (Climate Anxiety Support): Curated resources and simple coping exercises.
Community Hub (HCMC): Directory of HCMC emergency services, shelters, and curated preparedness tips.
Settings & Profile: User preferences, notification settings, progress tracking.
The visual interface will adhere to the "Calm Resilience" theme, employing a supportive color palette (warm neutrals, with #81B29A as primary accent and #F2CC8F as secondary), clear typography, and intuitive iconography.

















New User Flow:
Emergency Stockpile:


Flood Guidance and Well being:


Low-fidelity wireframe:






High-fidelity wireframes (Before changing to Calm Resilience theme):





3.4.2 Software Architecture (Flutter & Firebase)
PrepPal will utilize a component-based architecture:
Presentation Layer (UI)
Composed of Flutter widgets representing screens and UI elements.
Handles user input and displays data from the Business Logic Layer.
Navigation managed by Flutter's Navigator.
Business Logic Layer (State & Services)
State Management: For simpler global state (e.g., user authentication status, theme preferences), a solution like Riverpod will be used. For more complex state interactions (e.g., managing gamification logic or intricate stockpile updates), ChangeNotifier with Consumer widgets will be employed.
Service Modules (Dart): Encapsulate specific functionalities like stockpile calculations, gamification rules, processing HCMC content, and managing simulated alert logic.
Data Layer
Firebase SDKs: Integrated via official FlutterFire packages (e.g., cloud_firestore, firebase_auth) to handle authentication, database interactions (CRUD operations on Firestore collections for user data), and file storage.
Local Storage (Offline First): Critical data such as the user's stockpile inventory, emergency plans, and essential HCMC preparedness guidance will be stored locally using a robust solution like sqflite (for SQLite). This ensures core functionality when offline. Data will be fetched from Firebase when online and cached/updated locally.
Data flow pattern:
UI Widget → State Management/Service → Firebase SDKs/Local Storage → Update State → UI Re-render





3.5 Identification of Most Important Technologies and Methods
Technologies 
Frontend Framework: Flutter (using Dart).
Backend as a Service (BaaS): Firebase (Firestore Database, Authentication, Storage).
Local Data Persistence: sqflite for robust offline functionality.
Navigation: Flutter's Navigator package.
State Management: Riverpod, ChangeNotifier.
Design & Prototyping Tools: Hand-drawn sketches, Figma (high-fidelity mockups).
Version Control: Git and GitHub.
Project Management: Gantt Chart.
Key Methodologies 
User-Centered Design (UCD): An iterative process based on user flows, wireframes, mockups, and planned usability testing.
Agile Development Principles: Using iterative development sprints to deliver functional increments.
Gamification Design Principles: Applied to enhance engagement in preparedness tasks like stockpile management.
Offline-First Strategy: Prioritizing local data storage and functionality for critical features.
3.6 Plan of Work

Phase 1 (Weeks 1-3) 
Project selection, initial research, literature review commencement, project pitch.
Phase 2 (Weeks 4-8)
Completion of Literature Review.
Tech stack finalization.
Development of user flows, low-fidelity, and ongoing high-fidelity mockups.
App architecture design.
Initial Flutter project setup and UI shells, Firebase setup.
Phase 3 (Weeks 7-8)
Develop one core, technically challenging feature.
Submit the Preliminary Draft Report.

Phase 4 (Weeks 9-16) 
Implement core features.
Integrate Firebase.
Implement basic gamification elements.
Refine offline data handling.

Phase 5 ( Weeks 16-19)
Implement selected "Exceeding Expectations" features.
Conduct thorough usability testing.
Iterate on design and functionality.
Performance checks and bug fixing.
Phase 6 (Weeks 19-21)
Final app polishing, bug fixes.
Complete report and video.
Submission.












3.7 Plan for Testing and Evaluation
Usability Testing:
Method: Iterative usability testing will be conducted at key milestones. A think-aloud protocol will be used with 3-5 proxy users representing HCMC residents. Users will be given specific tasks to complete.
Metrics: Task completion rate, time on task, number of errors, subjective feedback via a post-test questionnaire (e.g., System Usability Scale - SUS, or a custom satisfaction survey).
Tools: Screen recording software (e.g., OBS Studio), note-taking. Feedback will be analyzed for patterns and used to iterate on the UI/UX design.
Feature Prototype Evaluation:
The chosen feature prototype (Offline Stockpile Management) will be evaluated for:
Functional Correctness: Does it perform all intended operations accurately (e.g., adding, editing, deleting items, storing data offline, setting/triggering reminders)?
Technical Soundness: Is the Flutter/Firebase/sqflite implementation efficient and robust? (Code review, testing edge cases).
Usability (Mini-Test): A quick usability test with 1-2 users focusing solely on this feature.
Alignment with Project Goals: How well does this feature demonstrate the feasibility of achieving a key aspect of PrepPal (e.g., supporting long-term preparedness through offline tools) [10, 14]?
Gamification Effectiveness:
Method: Post-usability test questions and in-app feedback prompts will gauge user perception of gamified elements to measure impact on sustained engagement [9].
Metrics: Qualitative feedback on engagement, motivation. Completion rates of gamified tasks.
Content Accuracy & HCMC Relevance:
Method: Cross-referencing HCMC-specific information with publicly available official HCMC resources and disaster management guidelines from reputable Vietnamese sources [2, 17].
Metrics: Accuracy of information, relevance of guidance to HCMC context.
Offline Functionality Testing:
Method: Rigorous testing of all features designed to work offline, as justified by the need for access during network disruptions [10, 14]. This involves loading in airplane mode, simulating intermittent connectivity, and verifying data persistence.
Metrics: Feature availability, data integrity, app responsiveness during offline use.
Technical Performance:
Method: Using Flutter builtin Developer Tools to check for common issues.
Metrics: App startup time, screen transition smoothness, memory usage (basic checks), CPU usage during intensive tasks (e.g., list rendering).
Self-Evaluation Against Project Aims:
The ultimate evaluation will be a critical self-assessment of whether PrepPal achieves its primary objective. This will be based on the cumulative findings from all testing phases.
4. Feature Prototype - Offline-First Stockpile Management (747 words)
The core of PrepPal's utility lies in its ability to function reliably when it matters most: during a disaster when connectivity might be compromised. To demonstrate this critical aspect, I've developed a feature prototype focusing on the "Offline-First Stockpile Management" system. This is a tangible proof-of-concept for a feature that directly addresses the "Critical Need for Offline Access" identified in my literature review [10, 14].
4.1 Prototype Design and Implementation
My approach to this prototype was to build a robust, yet focused, implementation of the stockpile management feature, ensuring it could operate seamlessly both online and offline.
Technologies: The prototype leverages the power of Flutter for its cross-platform UI and application logic, providing a single codebase for both iOS and Android. For cloud synchronization and user authentication, I've integrated Firebase Firestore, a NoSQL cloud database that offers excellent real-time capabilities and offline persistence out-of-the-box. Crucially, for the offline-first aspect, I've employed sqflite, a Flutter plugin for SQLite databases, to manage local data storage. This combination allows for a resilient data architecture.
Functionalities: The prototype implements the core CRUD (Create, Read, Update, Delete) operations for stockpile items. Users can:
Add New Items: Input item name, quantity, category, and an optional expiry date.
View Stockpile: Browse a list of all added items, with basic filtering and sorting.
Edit Items: Modify details of existing items.
Delete Items: Remove items from their stockpile.
Offline Data Handling: The sqflite database acts as the primary source of truth when the device is offline. Any changes made by the user (adding, editing, deleting items) are immediately reflected in the local SQLite database.
Data Synchronization: When network connectivity is detected, the application intelligently synchronizes the local sqflite data with Firebase Firestore. This involves:
Initial Sync: On first login or when the app detects it's online after a period of being offline, it fetches the latest data from Firestore and merges it with the local database, resolving any simple conflicts (e.g., favoring the most recent modification).
Real-time Updates (when online): Changes made locally are pushed to Firestore, and changes from Firestore are pulled down to the local database, ensuring data consistency across devices and the cloud.
Offline Queuing: If a user makes changes while offline, these operations are queued locally. Once connectivity is restored, the queued operations are automatically pushed to Firestore.
Architecture: Within the Flutter framework, the prototype utilizes a clear separation of concerns. The UI is built with standard Flutter widgets. State management for the stockpile data is handled using a ChangeNotifier pattern, allowing the UI to react efficiently to data changes. Dedicated Dart service classes abstract the interactions with both the sqflite database and Firebase Firestore, ensuring the business logic remains clean and testable.

4.2 Demonstration of the Prototype
The prototype's effectiveness is best demonstrated through a simple user flow:
Initial Setup: The user logs in (authenticated via Firebase Authentication), and their existing stockpile data (if any) is synced from Firestore to the local sqflite database.
Offline Operation: The device's network is disabled (e.g., airplane mode). The user then proceeds to add, edit, and delete several stockpile items. The UI updates instantly, reflecting these changes, even without an internet connection.
Re-establishing Connectivity: The device's network is re-enabled. The application automatically detects the connection and initiates a background synchronization process. The locally made changes are pushed to Firestore, and any changes made from another device (if applicable) are pulled down, ensuring the stockpile is consistent everywhere.

This flow clearly illustrates the core "offline-first" capability: users can manage their critical preparedness items regardless of network availability, and their data remains consistent once connectivity is restored [10, 14].



4.3 Potential Improvements and Future Work
While the prototype successfully validates the offline-first approach, there are several avenues for improvement and expansion:
Advanced Conflict Resolution: For more complex scenarios where the same item might be modified simultaneously offline on multiple devices, a more sophisticated conflict resolution strategy (e.g., user-guided resolution, last-write-wins with versioning) could be implemented.
Background Synchronization: Currently, synchronization is primarily triggered when the app is active and connectivity changes. Implementing true background synchronization (e.g., using Flutter's workmanager or platform-specific background tasks) would enhance data freshness without requiring the app to be open.
Performance Optimization: For very large stockpiles, optimizing database queries and synchronization payloads could further improve performance.
This prototype, in essence, lays a solid foundation for PrepPal's critical offline capabilities, proving that the vision for a reliable, hyper-localized disaster preparedness application is not just ambitious, but entirely achievable.









5. References
[1] Alamon, A., Roxas, R. E., and Caparros, M. R. 2023. Acceptance of Mobile Application on Disaster Preparedness: Towards Decision Intelligence in Disaster Management. ResearchGate. (Conference Paper). Retrieved May 17, 2025 from https://www.researchgate.net/publication/371108859_Acceptance_of_Mobile_Application_on_Disaster_Preparedness_Towards_Decision_Intelligence_in_Disaster_Management
[2] C40 Cities. n.d. C40 Good Practice Guides: Ho Chi Minh City - Triple-A Strategic Planning for Climate Resilience. Retrieved May 17, 2025 from https://www.c40.org/case-studies/c40-good-practice-guides-ho-chi-minh-city-triple-a-strategic-planning/
[3] Crone, D. and Hjetland, G. J. 2024. Digital Mental Health Innovations in the Face of Climate Change: Navigating a Sustainable Future. Psychiatric Services 75, 6 (2024), 518–520. DOI:https://doi.org/10.1176/appi.ps.20240327
[4] FEMA. n.d. FEMA App. Apple App Store. Retrieved May 17, 2025 from https://apps.apple.com/us/app/fema/id474807486
[5] FEMA. n.d. FEMA Mobile Products. Federal Emergency Management Agency. Retrieved May 17, 2025 from https://www.fema.gov/about/news-multimedia/mobile-products
[6] FEMA. n.d. FEMA - Apps on Google Play. Google Play Store. Retrieved May 17, 2025 from https://play.google.com/store/apps/details?id=gov.fema.mobile.android
[7] FireSafe World. 2023. Disaster Preparedness in the Palm of Your Hand: Leveraging Technology for Resilient Communities. Retrieved May 17, 2025 from https://firesafeworld.com/disaster-preparedness-in-the-palm-of-your-hand-leveraging-technology-for-resilient-communities/
[8] Johnson, D., Deterding, S., Kuhn, K. A., Staneva, A., Stoyanov, S., and Hides, L. 2020. How can gamification be incorporated into disaster emergency planning? A systematic review of the literature. International Journal of Disaster Risk Reduction 49, (2020), 101649. DOI:https://doi.org/10.1016/j.ijdrr.2020.101649
[9] MoldStud. 2023. Benefits of Offline Features in Safety Notification Apps. Retrieved May 17, 2025 from https://moldstud.com/articles/p-benefits-of-offline-features-in-safety-notification-apps
[10] Nhan Dan Online. 2023. Zalo mini app released to support disaster response. (July 27, 2023). Retrieved May 17, 2025 from https://en.nhandan.vn/zalo-mini-app-released-to-support-disaster-response-post127542.html
[11] Parker, B. J., Lapsley, C., and O'Callaghan, P. 2024. Applying Digital Technology to Understand Human Experiences of Climate Change Impacts on Food Security and Mental Health: Scoping Review. JMIR Formative Research 8, (2024), e53355. DOI:https://doi.org/10.2196/53355
[12] Reuter, C., Ludwig, T., Ritzkatis, M., and Pipek, V. 2017. Persuasive System Design Analysis of Mobile Warning Apps for Citizens. In Proceedings of the 14th International Conference on Information Systems for Crisis Response and Management (ISCRAM).
[13] Setiobudi, A., Wibisono, W., and Hidayanto, A. N. 2023. Analysis of Offline-First App Technology in Raspberry Pi Edge Computing for Post-Disaster Hospital Situation. Figshare. DOI:https://doi.org/10.6084/m9.figshare.28801370.v1
[14] Suruliraj, B. and Meela, S. M. 2020. Bota: A Personalized Persuasive Mobile App for Sustainable Waste Management. In Adjunct Proceedings of the 15th International Conference on Persuasive Technology (PERSUASIVE 2020).
[15] The Investor. 2023. Disaster prevention efforts get a boost with Zalo mini-app: official. (July 27, 2023). Retrieved May 17, 2025 from https://theinvestor.vn/disaster-prevention-efforts-get-a-boost-with-zalo-mini-app-official-d6024.html
[16] World Bank Group. 2021. Climate Risk Profile: Vietnam. (April 2021). Retrieved May 17, 2025 from https://climateknowledgeportal.worldbank.org/sites/default/files/2021-04/15077-Vietnam%20Country%20Profile-WEB.pdf


