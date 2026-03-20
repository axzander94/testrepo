# Start from a raw idea
/agent swap idea-to-epic

I want to add a self-service refund feature for customers. 
Currently refunds require a support agent to manually process them 
in the back office. We lose about 2 hours of support time daily on 
this. Customers complain about the 3-day wait. The system is our 
payments microservice in src/services/payments/.

# After epic is generated, run the full pipeline
/agent swap arch-pipeline

# After tech-spec-writer completes, generate test cases
/agent swap gherkin-writer

Read .kiro/specs/self-service-refund/ and generate full Gherkin 
coverage for all stories.