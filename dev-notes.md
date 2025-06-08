# PrepPal - Developer Notes 

## Week 1

Achieved:
Thoroughly reviewed all Level 6 module project templates to understand the scope and requirements.
Identified CM3050 Mobile Development Project Idea 1: "Developing a Mobile App for Local Disaster Preparedness and Response" as a strong candidate due to its real-world impact and alignment with my interests.
Set up my development environment and project management tools (e.g., Trello for task tracking, Git repository on GitHub).

Planned:
Deep dive into the specifics of the chosen project template (CM3050, Idea 1) and its recommended resources.
Brainstorm initial modification ideas to personalize the project for HCMC context while adhering to core requirements.
Start preliminary research on existing disaster preparedness apps mentioned in the template and beyond.

## Week 2

Achieved:
I have contacted my tutor regarding some modifications I wish to make to the two potential projects that I'm having my eyes on for mobile development.
Upon receiving feedback that my proposed changes are too extensive to be acceptable, I scaled it back a bit and received positive feedback.
Thus I have decided I will work on the Disaster Awareness mobile app project ("Developing a Mobile App for Local Disaster Preparedness and Response").
Have also done some preliminary research on current competitors on the market (e.g., FEMA app, Red Cross apps, Zalo Mini-App in Vietnam).

Planned:
Do an in-depth research on competitors (FEMA, Zalo, etc.) and previous academic work (gamification, persuasive tech, HCMC context), focusing on gaps and opportunities for a hyper-localized HCMC solution.
Sketch out a general outline and core features of the app, focusing on how it can be tailored for HCMC (e.g., specific flood/heat stress guidance).
Start planning on features and themes, particularly how to incorporate gamification for preparedness tasks and address long-term engagement.
Divide the workload for the coming weeks into more manageable pieces for the literature review and initial design phases.

## Week 3

Achieved:
Conducted extensive research on disaster preparedness apps (commercial and academic prototypes), gamification in mobile applications, user engagement strategies (persuasive technology), and the psychological aspects of disaster preparedness (climate anxiety)
Analyzed academic papers on mobile technology in disaster management, focusing on user needs, offline capabilities, community resilience, and the effectiveness of various approaches.
Started drafting the literature review, synthesizing findings, and identifying key gaps that PrepPal can address (e.g., lack of hyper-localization, long-term support, psychological well-being features in existing apps).
Began conceptualizing the unique value proposition of PrepPal for HCMC, considering specific local risks like urban flooding and heat stress.

Planned:
Continue drafting and refining the literature review, aiming for around 2500 words.
Solidify the core theme and name for the app.
Develop a preliminary project plan and start outlining the project proposal/pitch, including a clear problem statement and proposed solution.

## Week 4

Achieved:
I have decided on the name and theme of the app. Which would be PrepPal and it will focus on the outlined requirements in the original template file (CM3050 Project Idea 1), but with add-ons that focus on longer-term preparedness, HCMC-specific needs, and psychological well-being.
I have compiled my research findings (literature review summary, competitor analysis, PrepPal concept) into a PowerPoint for the project pitch, used mostly stock images from Pixabay as graphics, but also used some AI-generated images where stock images were not sufficient.
I have made some preliminary plans for the project, including key features like HCMC-specific risk info, gamified checklists for kit building, stockpile management, (simulated) location-based alerts, and a local resource hub.
I have filmed and submitted the pitch video for PrepPal.

Planned:
Finalize the detailed project plan in the form of a Gantt chart.
Sketch out rudimentary user flow diagrams for core app interactions (onboarding, creating a kit, viewing an alert).
Begin in-depth research into specific languages and tooling (React Native/Expo vs. Flutter, Supabase vs. Firebase).
Start thinking about the app's information architecture and overall navigation structure.

## Week 5

Achieved:
Created a detailed Gantt chart for tracking project progress and milestones.
Developed initial user flow diagrams for key app features: onboarding with HCMC personalization, adding/managing stockpile items, accessing HCMC-specific risk information, and using a climate anxiety support feature.
Began creating low-fidelity wireframes (hand-drawn sketches) for the main screens of PrepPal, focusing on layout and core elements.
Researched tech stack options more thoroughly: compared Flutter (Dart) with React Native (JavaScript/TypeScript) for frontend, and Firebase with Supabase for backend. Weighed pros and cons regarding learning curve, community support, offline capabilities, and feature sets relevant to PrepPal.
Continued refining the literature review based on insights gained during the initial design process, ensuring it aligns with the app's evolving concept.

Planned:
Finalize the literature review draft for the upcoming second peer review submission.
Make a firm decision on the primary tech stack (Frontend framework: Flutter/React Native, Backend service: Firebase/Supabase).
Translate low-fidelity wireframes into high-fidelity digital wireframes (using Figma)
Start outlining the "Design" chapter of the project report, including app architecture, UI/UX considerations, and justifications for design choices.

## Week 6

Achieved:
I've finished the literature review process and written a 2500-word long part on it (submitted for the second peer review).
I've updated the Gantt chart for progress tracking, adjusting timelines based on the literature review completion.
I've sketched out some rudimentary user flow diagrams and digitized the main ones, showing user interaction paths.
I'm still torn between ReactNative/Expo and Flutter for the language. I'm going to use Supabase as the backend. (Self-correction from user: This was the previous state, decision will be made in Week 7/8)

Planned:
Finalize the decision on the frontend framework this week.
Start detailing the app's architecture design (e.g., Layered Architecture, MVVM/BLoC if Flutter is chosen), considering offline data storage and Firebase/Supabase integration.
Begin writing the main sections of the "Design" document (user flows, wireframes, architecture) for the third peer review.
Stick to the progress on my Gantt chart.

## Week 7

Achieved:
I will be using Expo/React-Native for the frontend and Supabase for the backend. I have prior experience with React Native and Supabase.
Designed the app architecture: opted for a BLoC (Business Logic Component) pattern with React, separating UI, business logic, and data layers. Mapped out data models for Supabase
Drafted a significant portion of the "Design" document for the third peer review.

Planned:
Complete the high-fidelity mockups in Figma for key screens.
Finalize and submit the "Design" document for the third peer review.
Set up the React Native/Expo development environment and create the initial project structure.
Begin implementing the basic UI shells for the main screens based on Figma designs.
Set up the Supabase project and configure basic authentication.

## Week 8

Achieved:
Finalized the "Design" document (including user flows, architecture, wireframes, and initial mockups) for the third peer review.
I will be using Expo/React-Native for the frontend and Supabase for the backend. I have prior experience with React Native and Supabase and it would be seamless for me.
Design Progress:
Finished the low-resolution wireframes (hand-drawn sketches from earlier weeks).
Currently actively working on and nearing completion of the high-resolution mockups in Figma for all primary screens.
Initial Development Setup:
Set up the Expo/React Native development environment, created the PrepPal project, and structured the initial folders for BLoC architecture.
Implemented the basic UI shells for 2-3 main screens in React Native based on the Figma mockups (e.g., Home Dashboard, initial Preparedness Hub screen).
Successfully set up the Supabase project, enabled Authentication (Email/Password for now), and designed the initial Supabase database structure for user profiles and basic HCMC content.

Planned:
Complete all high-fidelity mockups in Figma and create a clickable prototype for key user flows.
Focus on implementing one core "technically challenging" feature for the Week 10 prototype. Considering either:
Offline Stockpile Management: Implementing robust local data storage for the stockpile feature, including adding/editing items and calculating expiry dates. This would be technically challenging due to managing local persistence and potential future sync logic.
HCMC-Specific Alert Simulation with Interactive Guidance: Developing the UI for displaying detailed, multi-stage simulated alerts tailored to HCMC scenarios (e.g., a flood progressing), with actionable guidance steps that users can interact with. This tests UI complexity and state management.
Begin coding the chosen feature prototype.
Start drafting the "Introduction" and "Feature Prototype" chapters for the Week 10 preliminary report.
Revise the "Literature Review" and "Design" chapters based on peer review feedback (once received) and my own evolving understanding.