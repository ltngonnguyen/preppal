PrepPal: a Hyper-Localized Disaster Preparedness Application for Ho Chi Minh City
1. Introduction
The problem area I have chosen to focus on is the pressing need for innovative solutions to bolster community resilience against the rising impacts of climate change and the increasing frequency of urban disasters. To that end, I am proposing PrepPal, a hyper-localized mobile application designed to elevate disaster preparedness and response, tailored specifically for the residents of Ho Chi Minh City (HCMC), Vietnam. I believe that HCMC's distinct vulnerabilities, particularly its susceptibility to severe urban flooding and heat stress (C40 Cities, n.d.; World Bank Group, 2021), demand a focused strategy that the more generic, one-size-fits-all tools currently on the market often lack.
In the process of conceptualizing this project, I've also conducted an extensive literature review to assess the state of the art, examining both commercial disaster preparedness applications and relevant academic research to identify critical gaps that justify PrepPal's development. My investigation will explore several key themes:
The effectiveness of existing applications.
Strategies for long-term user engagement, including the use of gamification and persuasive technology.
The integration of psychological support to address climate anxiety.
The critical importance of offline functionality in a disaster scenario.
Technology's potential role in fostering genuine community resilience.
The overarching goal of this report is to demonstrate how PrepPal is strategically engineered to address these identified needs. I aim to contribute a valuable and contextually relevant tool for the HCMC community. I believe this attempt is both novel and ambitious, and through this project, I hope to provide a comprehensive solution that, in the spirit of my favourite saying, proves to be not just another model, but a useful one (Hilbe, 2009).

2. Review of Existing Commercial Disaster Preparedness Applications
An examination of current commercial offerings, ranging from globally recognized platforms to more localized efforts, reveals that significant gaps remain. I believe these gaps are particularly apparent concerning deep localization, sustained user engagement, and a more holistic approach to user support.
2.1. FEMA App (USA)
The FEMA App, developed by the U.S. Federal Emergency Management Agency, stands as a prominent example of a government-backed disaster preparedness tool (FEMA, n.d.-a). Its stated aim is to provide a comprehensive resource for the American public, covering the planning, protection, and recovery phases of a disaster.
Key Features (from FEMA, n.d.-a; FEMA, n.d.-b):
Real-time weather and emergency alerts from the National Weather Service (NWS) and the Integrated Public Alert and Warning System (IPAWS) for user-specified locations.
Guidance on creating family emergency plans and assembling preparedness kits.
Locators for finding nearby shelters and information on accessing FEMA assistance .
Inclusion of accessibility features.
Strengths: As an official government application, it serves as an authoritative and, presumably, reliable source of information. The ability to monitor alerts for multiple locations and the focus on accessibility are also notable strengths.
Limitations and Relevance to PrepPal: The primary limitation of the FEMA app for a global audience, and specifically for a project targeting Ho Chi Minh City, is its inherent US-centricity. Its data sources, such as the NWS and IPAWS, and its assistance information are only relevant to residents of the United States (FEMA, n.d.-a). More critically, user feedback often points to issues like "alert fatigue," stemming from what users perceive as irrelevant or duplicate notifications, even with location precision (FEMA, n.d.-a; FEMA, n.d.-c). From my perspective, this highlights a significant challenge: technical accuracy in alerting is insufficient if it doesn't account for user perception and context.
Furthermore, the application appears to be lacking in robust features designed for proactive, ongoing engagement, such as detailed stockpile management or dedicated support for climate-related anxiety. I find that this underscores a significant opportunity for an application like PrepPal. A new approach could provide a solution that is not only hyper-localized to the specific risks of HCMC (e.g., urban flooding, heat stress) but is also fundamentally designed to foster sustained user engagement and support psychological well-being.
2.2. "Vietnam Disaster Prevention" Zalo Mini-App (Vietnam)
A more locally relevant example is the "Vietnam Disaster Prevention" Mini-App, which is integrated within the popular Zalo messaging platform in Vietnam. This initiative represents a collaboration between Vietnam's National Steering Committee for Natural Disaster Prevention and Control and UNICEF (Nhan Dan Online, 2023a; Nhan Dan Online, 2023b).
Key Features (from Nhan Dan Online, 2023b; The Investor, 2023): 
A "Relief Connectivity" function for users to request aid. 
An "Emergency Contact" list for quick communication. A "Disaster Report" function allowing users to submit information from the scene.
A knowledge section covering various disaster types and appropriate responses, which is notably available in several ethnic minority languages.
Leverages the Zalo platform to disseminate urgent alerts.
Strengths: Its integration within a ubiquitous platform like Zalo provides a massive potential reach and significantly lowers barriers to adoption (The Investor, 2023). Furthermore, the official government backing lends it a high degree of credibility, and I find the inclusion of multilingual support to be a significant and commendable step towards inclusivity.
Limitations and Relevance to PrepPal: While this is a laudable effort, especially for its reach and response-oriented features, my analysis suggests the Zalo Mini-App is primarily focused on the immediate aftermath of disasters, with functions geared toward relief and reporting. There appears to be less emphasis on cultivating proactive, long-term preparedness habits. I see a lack of features such as interactive planning tools, skill-building modules, or sophisticated stockpile management systems.
As a "mini-app," it might also face inherent limitations in UI complexity and, crucially, offline functionality when compared to a dedicated native application. This presents a clear niche for PrepPal. The project can serve as a complementary tool, designed specifically to build and maintain long-term preparedness within HCMC's unique urban context, moving beyond simple information dissemination toward active and sustained user engagement in readiness.
3. Review of Relevant Academic Research & Methodologies
Academic research offers a critical foundation for designing effective disaster preparedness tools, especially when considering user engagement, behavior change, and the multifaceted impacts of these events.
3.1. Gamification for Sustained Engagement
Gamification, which involves integrating game-design elements into non-game contexts, is an approach that has been widely explored for its potential to improve user motivation and learning in domains like disaster preparedness.
Key Research Findings: I've found that systematic reviews confirm that gamification can enhance initial user motivation, participation, and knowledge acquisition (Johnson et al., 2020). Elements such as points, badges, and leaderboards are commonly employed.
Limitations of Current Gamification Approaches: However, a significant challenge, as noted by Johnson et al. (2020), is the difficulty in achieving sustained, long-term engagement. The novelty can diminish over time, and I believe that poorly designed gamification can become ineffective or even demotivating. Many existing studies also lack methodological rigor or fail to base their designs on established behavior change theories.
Implications for PrepPal: These findings are crucial for the development of PrepPal. It is my belief that simply incorporating superficial game elements is an inherently lazy approach and will not foster the long-term habit formation required for disaster preparedness. Instead, PrepPal must utilize a more sophisticated, theory-driven gamification strategy. This means I will focus on individual motivation by addressing users' needs for personal growth (e.g., mastering preparedness skills), autonomy through personalized goals, and relatedness via community challenges specifically relevant to Ho Chi Minh City. My objective is the internalization of preparedness behaviors, not mere short-term task completion.
3.2. Persuasive Technology for Behavior Change
Persuasive Technology (PT) offers valuable frameworks and strategies for positively influencing user attitudes and behaviors, a goal that is highly relevant for encouraging proactive preparedness.
Core Principles and Strategies: The Persuasive System Design (PSD) model presents a structured approach, categorizing strategies such as personalization, self-monitoring, reminders, simplification (reduction), and establishing credibility (Oinas-Kukkonen & Harjumaa, 2009, as cited in Suruliraj & Meela, 2020). Research confirms that user acceptance of disaster-related applications is strongly correlated with their perceived usefulness, ease of use, and trust in the source of information (Alamon et al., 2023).
User Needs in Disaster Apps: Existing research underscores that users place a high value on receiving reliable and timely alerts, clear evacuation information, and trustworthy guidance (Alamon et al., 2023; Reuter et al., 2017).
Implications for PrepPal: PrepPal's design will be explicitly guided by PT principles. Building and maintaining user trust is paramount. This requires transparency, reliability, and credible, HCMC-specific information. Key strategies will include personalization, such as risk assessments for different HCMC districts and tailored checklists; self-monitoring, for tracking supply inventories and completed tasks; and reduction, which involves simplifying complex actions into more manageable steps.
3.3. Addressing Climate Anxiety through Digital Tools
The psychological impact of climate change and disaster risk, frequently described as "climate anxiety," is an increasingly significant concern. Digital tools are now emerging as a potential avenue for providing support.
The Rise of Climate Anxiety and Need for Support: There is a growing acknowledgment of the mental health effects, including anxiety, grief, and trauma, that are linked to climate change and disasters (Crone & Hjetland, 2024).
Potential of Digital Interventions: Research is currently exploring how mobile apps and other digital platforms can offer psychoeducation, coping strategies, and scalable mental health interventions to address these issues (Crone & Hjetland, 2024; Parker et al., 2024).
Implications for PrepPal: From what I can observe, current disaster applications largely overlook this dimension. This gives PrepPal a novel opportunity to be innovative by integrating features designed to help HCMC users manage climate anxiety. My approach would involve providing curated resources, evidence-based coping techniques like mindfulness exercises, and framing preparedness actions in a positive, empowering manner to support both physical safety and mental resilience.
3.4. Offline Functionality and Community Resilience Technologies
During a disaster, reliable access to information and effective community coordination are vital, particularly when conventional infrastructure is compromised.
Critical Need for Offline Access: Disasters often lead to disruptions in communication networks, which makes offline access to essential information and tools a necessity rather than a luxury (Setiobudi et al., 2023; MoldStud, 2023).
Role of Technology in Fostering Community Coordination: Technology can be leveraged to facilitate improved communication, information sharing, and mutual aid among residents and local organizations, thereby enhancing overall community resilience (FireSafe World, 2023).
Implications for PrepPal: It is imperative that PrepPal prioritizes robust offline functionality for its core features, including checklists, HCMC-specific guidance, user inventory data, and emergency contacts. Furthermore, there is significant potential to develop features that foster preparedness at the community level within HCMC neighborhoods, such as localized information sharing or tools for coordinating mutual aid, moving beyond the basic reporting functions seen in other applications.
4. Synthesis and Identified Gaps for PrepPal
This review of commercial applications and academic literature reveals several critical gaps that my project, PrepPal, is specifically designed to address, particularly within the HCMC context:
Lack of Hyper-Local Context: Global applications like FEMA's are not tailored to the specific climate risks of HCMC, such as its diverse flooding types and heat stress, nor do they account for local infrastructure or cultural nuances. Even national applications like the Zalo Mini-App, while valuable for their broad reach, may not provide the granular, neighborhood-level preparedness guidance that HCMC requires. PrepPal will prioritize this hyper-localization.
Deficiency in Long-Term Preparedness Support: From what I can observe, most current applications focus on initial planning or immediate response. There is a significant unmet need for tools that support the ongoing management of preparedness, such as detailed stockpile tracking with expiry alerts, reminders for skill maintenance, and adaptive guidance. PrepPal aims to fill this gap by fostering long-term preparedness habits.
Superficial or Ineffective Engagement Strategies: Many applications struggle with sustained user engagement, often due to issues like alert fatigue, as seen with the FEMA app, or the use of simplistic gamification that fails to maintain motivation over the long term (Johnson et al., 2020). It is my belief that this project must leverage deeper, theory-driven persuasive technology and meaningful gamification to cultivate intrinsic motivation and lasting behavior change.
Neglect of Psychological Well-being: The mental health dimension of disaster preparedness, especially climate anxiety, is almost entirely unaddressed by current applications. PrepPal sees an opportunity to be innovative in this area by integrating support features, thereby becoming a more holistic resilience tool.
Inconsistent Offline Functionality and Underdeveloped Community Features: While the necessity of offline access is acknowledged in research (Setiobudi et al., 2023), its implementation is often limited. Similarly, I find that tools for proactive, community-level coordination and mutual aid remain underdeveloped (FireSafe World, 2023). My approach with PrepPal is to ensure core features are robustly offline and to explore innovative methods for enhancing community resilience within HCMC.
In essence, while individual components of PrepPal's vision may exist in isolation in other products, no current solution appears to effectively integrate hyper-localization for HCMC, long-term preparedness tools, psychologically informed engagement strategies, climate anxiety support, reliable offline access, and community resilience features into a single, user-centric platform. This is the distinct niche that I intend for PrepPal to fill.


5. Design
5.1 Overview of the Project
PrepPal is a mobile application I have conceived to enhance disaster preparedness and community resilience, with a specific focus on the unique challenges faced by residents of HCMC. The project's primary objective is to address the critical gaps I have identified in current disaster preparedness applications by delivering a hyper-localized, engaging, and comprehensive tool. Its key features are designed as direct solutions to these shortcomings and include: HCMC-specific risk information, interactive emergency kit management with meaningful gamified elements, support for psychological well-being, access to local community resources, and robust offline functionality.
This project is grounded in the CM3050 Mobile Development Project Idea 1: Developing a Mobile App for Local Disaster Preparedness and Response. While I will adhere to the core requirements of that template, such as implementing gamification and location-based alerts (which will be simulated for HCMC-specific scenarios), my attempt with PrepPal is to be both original and ambitious. It expands significantly on the foundational idea by emphasizing the cultivation of long-term preparedness habits, ensuring hyper-localization to HCMC's distinct environmental and cultural context, and integrating support for psychological well-being—a dimension largely ignored by current tools.
5.2 Domain and Users
Domain: The project is situated within the domain of mobile application development for public safety and personal well-being, with a specialized focus on disaster preparedness and community resilience in a dense urban environment. It intersects with several key fields, including information dissemination, education, behavioral science (through the application of gamification and persuasive technology), and mental health support. All these facets will be tailored to the specific environmental challenges, such as urban flooding and heat stress, and the unique socio-cultural landscape of HCMC.


Users: The primary users of PrepPal are the residents of HCMC. I have identified the following user groups:


Individuals and Families: Those seeking to improve their personal and household preparedness for disasters relevant to their locality.
Diverse Demographics: While the application aims for broad appeal, I will make practical considerations for varying levels of technological proficiency and access. Crucially, language support will be provided, with Vietnamese as the primary language.
Community Members: Users who can benefit from localized information regarding emergency services, shelters, and curated advice. Although user-generated content moderation is outside the initial scope of this project, the inclusion of officially-sourced or community-vetted preparedness tips is planned.
In short, the application is intended to be accessible and useful for any individual residing in HCMC who owns a smartphone and wishes to become better prepared for emergencies specific to the city.
5.3 Justification of Design Choices
The design of PrepPal is directly informed by my literature review and a critical analysis of the specific needs of residents in Ho Chi Minh City (HCMC). Each design choice is purposefully made to address an identified gap.
Hyper-Localization (HCMC Focus):


Need: Generic disaster applications lack the granular detail required for HCMC, failing to address its unique risks (e.g., specific urban flooding patterns, heat stress), local alert systems, evacuation routes, and cultural context.
Design Choice: The application will therefore feature dedicated sections for HCMC-specific risk information. This includes interactive maps (simulated, or using available GIS data where possible) that highlight vulnerable areas, and guidance tailored to local scenarios. All content will be culturally appropriate and provided primarily in Vietnamese.
Justification: This approach enhances the relevance and provides actionable insights for HCMC users, thereby increasing the application's practical value and utility.
Long-Term Preparedness & Tracking:


Need: I have observed that many applications focus on one-time planning. However, sustained preparedness is an ongoing effort that requires continuous management.
Design Choice: Consequently, features for detailed stockpile management (with item categorization, quantity tracking, and expiry date reminders) and a personalized emergency plan builder are central to my design. Gamification will be specifically targeted at these areas to encourage consistent engagement.
Justification: This strategy promotes the development and maintenance of preparedness habits over time, moving beyond the superficiality of a mere initial setup.
Engaging User Experience (Gamification & UI/UX):


Need: As my research indicates, sustained user engagement is a major challenge for preparedness applications.
Design Choice: I will implement a "Calm Resilience" visual theme, which aims to create a supportive, non-alarming user interface. Gamification, such as progress bars and achievement badges for preparedness milestones, will be applied to core tasks like stockpile completion. The application's navigation will be intuitive, guided by a clear information architecture (see Section 3.4.1).
Justification: This design encourages continued use and interaction, making the often-daunting task of disaster preparedness more approachable and rewarding for the user.
Psychological Well-being (Climate Anxiety Support):


Need: The mental health impact of climate change and disaster risk is a dimension that is often overlooked in existing tools.
Design Choice: A dedicated section will provide users with curated resources, simple coping strategies (e.g., guided breathing exercises, positive self-talk prompts), and will link well-being with actionable preparedness steps to empower users.
Justification: My intent is to offer holistic support, acknowledging the emotional toll of disaster awareness and empowering users to manage it constructively.
Robust Offline Functionality:


Need: During a disaster, communication networks are frequently disrupted, making online-only tools unreliable.
Design Choice: Core interactive features—including the user's stockpile inventory, emergency plans, HCMC-specific guidance, and key emergency contacts—will be stored locally. I will utilize AsyncStorage or a similar React Native local storage solution, with data initially sourced from a Supabase backend or bundled with the application.
Justification: This ensures that critical information and tools are accessible to users when they are needed most, irrespective of internet connectivity.
Community Resources (HCMC Specific):


Need: There is a clear need for quick and reliable access to verified local support systems during emergencies.
Design Choice: The application will include a curated directory of HCMC emergency services, official community shelters, and potentially admin-vetted preparedness tips sourced from local community knowledge or official advisories.
Justification: This provides reliable, localized information, which enhances community-level awareness and improves access to support networks.
Technology Stack (React Native/Expo & Supabase):


Need: The project requires efficient cross-platform development, robust backend services, and presents an opportunity for me to build upon my existing skills.
Design Choice:
React Native with Expo: This framework allows for rapid development for both iOS and Android from a single JavaScript/TypeScript codebase. Expo simplifies the build process and provides access to native device features. My prior experience with this stack allows me to leverage existing knowledge while undertaking a more complex and ambitious application than previous projects. The framework's large community and extensive libraries are well-suited for a feature-rich application like PrepPal.
Supabase: I have chosen Supabase as it provides a scalable and easy-to-use backend solution, including a PostgreSQL database, authentication, and storage. While its real-time capabilities are not a primary focus for the initial offline-first design, they offer significant potential for future expansion. The simplicity of its API and client libraries integrates well with a React Native front-end.
Justification: I believe this technology stack offers an optimal balance of development speed, performance, community support, and backend capabilities required to successfully implement PrepPal's feature set, including its critical offline data handling and user authentication requirements.
5.4 Overall Structure of the Project
5.4.1 Information Architecture & Visual Interface (Mobile App)
The app will follow a user-centered information architecture, prioritizing ease of navigation and quick access to critical information. The main sections, accessible via a bottom navigation bar and a central Home/Dashboard, include:
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
The visual interface will adhere to the "Calm Resilience" theme, employing a supportive color palette (warm neutrals, with #81B29A as primary accent and #F2CC8F as secondary), clear typography, and intuitive iconography. High-fidelity mockups developed in Figma will guide the visual implementation. User flows and wireframes hand-drawn have been developed to map out user interactions within these sections.
Onboarding New User Flow:
Emergency Stockpile Item Management:
Flood Guidance and Well being:

5.4.2 Software Architecture (React Native & Supabase)
PrepPal will utilize a component-based architecture typical of React Native applications, with a focus on separating concerns for maintainability and testability.
Presentation Layer (UI):
Composed of React Native components (functional components with Hooks) representing screens and UI elements.
Managed by Expo for build and development utilities.
Handles user input and displays data from the Business Logic Layer.
Navigation managed by React Navigation.
Business Logic Layer (State & Services):
State Management: React Context API for simpler global state (e.g., user authentication status, theme preferences) and component-level state for local UI state. For more complex state interactions (e.g., managing gamification logic or intricate stockpile updates), useState and useEffect hooks will be combined with custom hooks encapsulating specific logic.
Service Modules/Custom Hooks (JavaScript/TypeScript): Encapsulate specific functionalities like stockpile calculations, gamification rules, processing HCMC content, and managing simulated alert logic.
Data Layer:
Supabase Client: Integrated via the official Supabase JavaScript library (@supabase/supabase-js) to handle authentication, database interactions (CRUD operations on PostgreSQL tables for user data, potentially some HCMC content if not bundled), and file storage (e.g., for user-uploaded profile pictures, if implemented).
Local Storage (Offline First): Critical data such as user's stockpile inventory, emergency plans, and essential HCMC preparedness guidance will be stored locally using React Native's AsyncStorage or a more robust solution like an SQLite database via an Expo-compatible library (e.g., expo-sqlite). This ensures core functionality when offline. Data will be fetched from Supabase when online and cached/updated locally. For this project, the initial HCMC content might be bundled with the app and updated from Supabase if an internet connection is available.
Data flow will generally be: UI Component -> State Management/Service Hook -> Supabase Client/Local Storage -> Update State -> UI Re-render.

5.5 Identification of Most Important Technologies and Methods
Frontend Framework: React Native with Expo (using JavaScript/TypeScript).
Backend as a Service (BaaS): Supabase (PostgreSQL Database, Authentication, Storage).
Local Data Persistence: React Native AsyncStorage or expo-sqlite for robust offline functionality.
Navigation: React Navigation library.
State Management: React Context API, useState, useEffect, custom Hooks.
Design & Prototyping Tools: Hand-drawn sketches, Figma (high-fidelity mockups and interactive prototypes).
Version Control: Git and GitHub.
Project Management: Trello/Asana and Gantt Chart.
Key Methodologies:
User-Centered Design (UCD): Iterative process based on user flows, wireframes, mockups, and planned usability testing.
Agile Development Principles: Iterative development sprints, focusing on delivering functional increments.
Gamification Design Principles: Applied to enhance engagement in preparedness tasks (e.g., stockpile management).
Offline-First Strategy: Prioritizing local data storage and functionality for critical features.
5.6 Plan of Work
The project is planned over approximately 20 weeks, with major phases outlined below. A detailed Gantt chart tracks specific tasks and deadlines.

Phase 1: Research, Proposal & Planning (Approx. Weeks 1-3) - Completed
Project selection, initial research, literature review commencement, project pitch.
Phase 2: In-depth Literature Review & Design Foundation (Approx. Weeks 4-8) - Nearing Completion
Completion of Literature Review.
Tech stack finalization (React Native/Expo, Supabase).
Development of user flows, low-fidelity, and ongoing high-fidelity mockups (Figma).
App architecture design.
Initial React Native/Expo project setup and UI shells, Supabase setup.
Phase 3: Core Feature Prototype & Preliminary Report (Approx. Weeks 7-8) - Current Active Phase
Develop one core, technically challenging feature (e.g., Offline Stockpile Management with Supabase sync logic, or HCMC-Specific Alert Simulation).
Prepare and submit the Preliminary Draft Report (Introduction, Revised Literature Review, Revised Design, Feature Prototype chapter & video).

Phase 4: Core Application Development (Approx. Weeks 9-16) - Upcoming
Implement core features: HCMC Risk Info, full Stockpile Management, Emergency Plan Builder, Well-being resources, Community Hub (curated content).
Integrate Supabase for authentication and data storage/retrieval for these features.
Implement basic gamification elements.
Refine offline data handling.

Phase 5: Advanced Features, Testing & Iteration (Approx. Weeks 16-19) - Upcoming
Implement selected "Exceeding Expectations" features (e.g., advanced stockpile reminders, interactive HCMC map elements).
Conduct thorough usability testing with user personas/proxy users.
Iterate on design and functionality based on testing feedback.
Performance checks and bug fixing.
Phase 6: Finalization & Report Submission (Approx. Weeks 19-21) - Upcoming
Final app polishing, bug fixes, and ensuring all requirements are met.
Complete the final project report and video demonstration.
Submission.

3.7 Plan for Testing and Evaluation
The evaluation of PrepPal will be a multi-faceted process, designed to rigorously assess usability, functionality, effectiveness in meeting its HCMC-specific objectives, and overall technical robustness.
Usability Testing:
Method: Iterative usability testing will be conducted at key milestones (e.g., after core feature implementation, after advanced feature implementation). A think-aloud protocol will be used with 3-5 proxy users representing HCMC residents (based on defined personas if direct HCMC user access is challenging). Users will be given specific tasks to complete (e.g., "Add three essential items to your emergency stockpile including one with an expiry date," "Find information on what to do during a major flood in District X," "Access a resource to help manage anxiety about potential disasters").
Metrics: Task completion rate, time on task, number of errors, subjective feedback via a post-test questionnaire (e.g., System Usability Scale - SUS, or a custom satisfaction survey).
Tools: Screen recording software (e.g., OBS Studio), note-taking. Feedback will be analyzed for patterns and used to iterate on the UI/UX design.
Feature Prototype Evaluation (Specifically for Week 10 Submission):
The chosen feature prototype (e.g., Offline Stockpile Management) will be evaluated for:
Functional Correctness: Does it perform all intended operations accurately (e.g., adding, editing, deleting items, storing data offline, setting/triggering reminders)?
Technical Soundness: Is the React Native/Supabase/AsyncStorage implementation efficient and robust? (Code review, testing edge cases).
Usability (Mini-Test): A quick usability test with 1-2 users focusing solely on this feature.
Alignment with Project Goals: How well does this feature demonstrate the feasibility of achieving a key aspect of PrepPal (e.g., supporting long-term preparedness through offline tools)?
Gamification Effectiveness:
Method: Post-usability test questions and in-app feedback prompts (if implemented) will gauge user perception of gamified elements (e.g., "Did the progress indicators for your stockpile motivate you?").
Metrics: Qualitative feedback on engagement, motivation. Completion rates of gamified tasks.
Content Accuracy & HCMC Relevance:
Method: Cross-referencing HCMC-specific information (risk data, emergency contacts, guidance) with publicly available official HCMC resources and disaster management guidelines from reputable Vietnamese sources. If possible, seek informal feedback from someone familiar with HCMC.
Metrics: Accuracy of information, relevance of guidance to HCMC context.
Offline Functionality Testing:
Method: Rigorous testing of all features designed to work offline. This involves:
Loading the app and using features with the device in airplane mode.
Simulating intermittent network connectivity.
Verifying data persistence (e.g., stockpile items saved offline are present when back online and correctly synced with Supabase if applicable).
Metrics: Feature availability, data integrity, app responsiveness during offline use.
Technical Performance:
Method: Using Expo's built-in performance monitoring tools and React Native Developer Tools to check for common issues.
Metrics: App startup time, screen transition smoothness, memory usage (basic checks), CPU usage during intensive tasks (e.g., list rendering).
Self-Evaluation Against Project Aims:
The ultimate evaluation will be a critical self-assessment of whether PrepPal achieves its primary objective: to provide a user-friendly, engaging, informative, and HCMC-tailored mobile application that demonstrably enhances users' disaster preparedness capabilities and supports their well-being. This will be based on the cumulative findings from all testing phases.
Contingency Plans:
Technical Challenges with React Native/Expo/Supabase: As this project serves as a learning opportunity, unforeseen complexities may arise. In the event that a specific complex integration, such as real-time offline data synchronization with Supabase, proves excessively time-consuming, a pragmatic approach will be taken. The feature will be simplified to a more manageable implementation, such as a manual "sync" button or a basic caching strategy. My primary mitigation strategy will involve rigorous consultation of online documentation, forums, and peer/tutor advice.
Time Constraints: The project's Gantt chart incorporates buffer periods for unexpected delays. However, should significant delays occur, features designated as "Exceeding Expectations" will be de-prioritized. My focus will remain steadfast on delivering a polished core application that comprehensively meets all "Meeting Expectations" criteria.
Limited Access to HCMC-Specific Data/Users: In the event that granular, real-time HCMC data is unobtainable, the application will utilize well-researched, representative simulated data for alerts and map overlays. This limitation will be transparently documented within the project. For user testing, should direct access to HCMC residents prove unfeasible, I will create detailed user personas based on literature about HCMC demographics and needs. Testing will then be conducted with proxy users who will be instructed to adopt these personas.
Feature Creep: To ensure timely project completion, strict adherence to the defined feature list will be maintained. Any new concepts or ideas that emerge during development will be systematically logged for potential future iterations but will not be incorporated into the current project scope.


6. References
Alamon, A., Roxas, R. E., & Caparros, M. R. (2023). Acceptance of Mobile Application on Disaster Preparedness: Towards Decision Intelligence in Disaster Management. [Conference Paper]. ResearchGate. Retrieved May 17, 2025, from https://www.researchgate.net/publication/371108859_Acceptance_of_Mobile_Application_on_Disaster_Preparedness_Towards_Decision_Intelligence_in_Disaster_Management
C40 Cities. (n.d.). C40 Good Practice Guides: Ho Chi Minh City - Triple-A Strategic Planning for Climate Resilience. Retrieved May 17, 2025, from https://www.c40.org/case-studies/c40-good-practice-guides-ho-chi-minh-city-triple-a-strategic-planning/
Crone, D., & Hjetland, G. J. (2024). Digital Mental Health Innovations in the Face of Climate Change: Navigating a Sustainable Future. Psychiatric Services, 75(6), 518-520. https://doi.org/10.1176/appi.ps.20240327 (Based on ResearchGate pre-print: https://www.researchgate.net/publication/385743329_Digital_Mental_Health_Innovations_in_the_Face_of_Climate_Change_Navigating_a_Sustainable_Future)
FEMA. (n.d.-a). FEMA App. Apple App Store. Retrieved May 17, 2025, from https://apps.apple.com/us/app/fema/id474807486
FEMA. (n.d.-b). FEMA Mobile Products. Federal Emergency Management Agency. Retrieved May 17, 2025, from https://www.fema.gov/about/news-multimedia/mobile-products
FEMA. (n.d.-c). FEMA - Apps on Google Play. Google Play Store. Retrieved May 17, 2025, from https://play.google.com/store/apps/details?id=gov.fema.mobile.android
FireSafe World. (2023). Disaster Preparedness in the Palm of Your Hand: Leveraging Technology for Resilient Communities. Retrieved May 17, 2025, from https://firesafeworld.com/disaster-preparedness-in-the-palm-of-your-hand-leveraging-technology-for-resilient-communities/
Johnson, D., Deterding, S., Kuhn, K. A., Staneva, A., Stoyanov, S., & Hides, L. (2020). How can gamification be incorporated into disaster emergency planning? A systematic review of the literature. International Journal of Disaster Risk Reduction, 49, 101649. (Based on ResearchGate version: https://www.researchgate.net/publication/341037506_How_can_gamification_be_incorporated_into_disaster_emergency_planning_A_systematic_review_of_the_literature)
MoldStud. (2023). Benefits of Offline Features in Safety Notification Apps. Retrieved May 17, 2025, from https://moldstud.com/articles/p-benefits-of-offline-features-in-safety-notification-apps
Nhan Dan Online. (2023a, July 27). Zalo mini app released to support disaster response. Retrieved May 17, 2025, from https://en.nhandan.vn/zalo-mini-app-released-to-support-disaster-response-post127542.html
Nhan Dan Online. (2023b, July 27). Zalo mini app released to support disaster response. Retrieved May 17, 2025, from https://en.nhandan.vn/zalo-mini-app-released-to-support-disaster-response-post127542.html#:~:text=Society-,Zalo%20mini%20app%20released%20to%20support%20disaster%20response,in%20case%20of%20disaster%20emergencies.&text=The%20app%20is%20expected%20to%20help%20people%20cope%20with%20natural%20disasters%20more%20effectively
Parker, B. J., Lapsley, C., & O'Callaghan, P. (2024). Applying Digital Technology to Understand Human Experiences of Climate Change Impacts on Food Security and Mental Health: Scoping Review. JMIR Formative Research, 8, e53355. https://doi.org/10.2196/53355 (Based on PMC version: https://pmc.ncbi.nlm.nih.gov/articles/PMC11303902/)
Reuter, C., Ludwig, T., Ritzkatis, M., & Pipek, V. (2017). Persuasive System Design Analysis of Mobile Warning Apps for Citizens. In Proceedings of the 14th International Conference on Information Systems for Crisis Response and Management (ISCRAM). (Based on CEUR-WS.org version: https://ceur-ws.org/Vol-1817/paper7.pdf)
Setiobudi, A., Wibisono, W., & Hidayanto, A. N. (2023). Analysis of Offline-First App Technology in Raspberry Pi Edge Computing for Post-Disaster Hospital Situation. Figshare. Journal contribution. https://doi.org/10.6084/m9.figshare.28801370.v1 (Retrieved from https://figshare.com/articles/journal_contribution/Analysis_of_Offline-First_App_Technology_in_Raspberry_Pi_Edge_Computing_for_Post-Disaster_Hospital_Situation/28801370)
Suruliraj, B., & Meela, S. M. (2020). Bota: A Personalized Persuasive Mobile App for Sustainable Waste Management. In Adjunct Proceedings of the 15th International Conference on Persuasive Technology (PERSUASIVE 2020). (Based on CEUR-WS.org version: https://ceur-ws.org/Vol-2629/6_ppt_suruliraj.pdf)
The Investor. (2023, July 27). Disaster prevention efforts get a boost with Zalo mini-app: official. Retrieved May 17, 2025, from https://theinvestor.vn/disaster-prevention-efforts-get-a-boost-with-zalo-mini-app-official-d6024.html
World Bank Group. (2021, April). Climate Risk Profile: Vietnam. Retrieved May 17, 2025, from https://climateknowledgeportal.worldbank.org/sites/default/files/2021-04/15077-Vietnam%20Country%20Profile-WEB.pdf
