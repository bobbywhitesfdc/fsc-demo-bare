#!/bin/bash

# Salesforce FSC Insurance Demo - Scratch Org Setup Script
# This script creates a scratch org with FSC Insurance configuration and sample data

# Exit on any error
set -e
# Treat unset variables as errors
set -u
# Fail on pipe errors
set -o pipefail

echo "=========================================="
echo "FSC Insurance Demo - Scratch Org Setup"
echo "=========================================="

# Step 1: Create scratch org definition file
echo "Creating scratch org definition..."
mkdir -p config
cat > config/project-scratch-def.json << 'EOF'
{
  "orgName": "FSC Insurance Demo",
  "edition": "Developer",
  "features": ["PersonAccounts", "ServiceCloud", "FinancialServicesInsuranceUser", "FinancialServicesUser:10"],
  "settings": {
    "lightningExperienceSettings": {
      "enableS1DesktopEnabled": true
    },
    "communitiesSettings": {
      "enableNetworksEnabled": true
    }
  }
}
EOF

# Step 2: Create the scratch org
echo "Creating scratch org (this may take a few minutes)..."
sf org create scratch --definition-file config/project-scratch-def.json --alias FSCDEMO --duration-days 30 --set-default --wait 20

# Step 3: Push metadata to enable Insurance objects
echo "Enabling Insurance standard objects..."
# Note: InsurancePolicy, InsurancePolicyParticipant, and Producer are standard objects
# They should be available by default in orgs with appropriate licenses

# Step 4: Create data generation script
echo "Creating data generation script..."
mkdir -p scripts
cat > scripts/generate-insurance-data.apex << 'EOF'
// Generate Insurance Demo Data using Standard Objects

// Get Person Account Record Type
Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

List<Account> agencies = new List<Account>();
List<Contact> agentContacts = new List<Contact>();
List<Producer> producers = new List<Producer>();
List<Account> customers = new List<Account>();
List<InsurancePolicy> policies = new List<InsurancePolicy>();
List<InsurancePolicyParticipant> participants = new List<InsurancePolicyParticipant>();

// Array of sample agency names
String[] agencyNames = new String[]{
    'Premier Insurance Partners', 'Coastal Coverage Group', 'Mountain View Insurance',
    'Metropolitan Insurance Solutions', 'Heritage Insurance Advisors', 'Pioneer Protection Services',
    'Summit Insurance Group', 'Valley Insurance Associates', 'Lakeside Coverage Partners',
    'Horizon Insurance Agency', 'Gateway Insurance Services', 'Crossroads Insurance Group',
    'First Choice Insurance', 'Liberty Insurance Partners', 'United Coverage Solutions',
    'National Insurance Network', 'Regional Insurance Advisors', 'Community Insurance Group',
    'Advantage Insurance Services', 'Premier Coverage Partners', 'Elite Insurance Associates',
    'Trusted Insurance Advisors', 'Family First Insurance', 'Secure Future Insurance',
    'Guardian Insurance Group', 'Nationwide Coverage Partners', 'American Insurance Solutions',
    'Continental Insurance Services', 'Alliance Insurance Group', 'Pinnacle Insurance Partners',
    'Sterling Insurance Associates', 'Golden State Insurance', 'Evergreen Insurance Group',
    'Beacon Insurance Services', 'Meridian Insurance Partners', 'Atlas Insurance Solutions',
    'Compass Insurance Group', 'North Star Insurance Agency', 'Keystone Insurance Partners',
    'Crown Insurance Services', 'Diamond Insurance Group', 'Platinum Coverage Partners',
    'Silver Shield Insurance', 'Bronze Star Insurance', 'Victory Insurance Group',
    'Triumph Insurance Partners', 'Legacy Insurance Services', 'Foundation Insurance Group',
    'Cornerstone Insurance Partners', 'Benchmark Insurance Solutions'
};

// Step 1: Create 50 Insurance Agencies (Business Accounts)
System.debug('Creating 50 Insurance Agencies...');
for(Integer i = 0; i < 50; i++) {
    Account agency = new Account();
    agency.Name = agencyNames[i];
    agency.Type = 'Insurance Agency';
    agency.Phone = '555-' + String.valueOf(1000 + i).leftPad(4, '0');
    agency.BillingStreet = String.valueOf(100 + i*10) + ' Main Street';
    agency.BillingCity = (Math.mod(i, 5) == 0) ? 'New York' : 
                        (Math.mod(i, 5) == 1) ? 'Los Angeles' : 
                        (Math.mod(i, 5) == 2) ? 'Chicago' : 
                        (Math.mod(i, 5) == 3) ? 'Houston' : 'Phoenix';
    agency.BillingState = (Math.mod(i, 5) == 0) ? 'NY' : 
                         (Math.mod(i, 5) == 1) ? 'CA' : 
                         (Math.mod(i, 5) == 2) ? 'IL' : 
                         (Math.mod(i, 5) == 3) ? 'TX' : 'AZ';
    agency.BillingPostalCode = String.valueOf(10000 + i*100);
    agencies.add(agency);
}
insert agencies;
System.debug('Created ' + agencies.size() + ' agencies');

// Step 2: Create 3 Agent Contacts per Agency
System.debug('Creating Agent Contacts...');
String[] firstNames = new String[]{'James', 'Michael', 'Robert', 'John', 'David', 'William', 'Richard', 'Joseph', 'Thomas', 'Christopher', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen'};
String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'};

Integer agentCount = 0;
for(Account agency : agencies) {
    for(Integer j = 0; j < 3; j++) {
        Contact agentContact = new Contact();
        agentContact.FirstName = firstNames[Math.mod(agentCount, firstNames.size())];
        agentContact.LastName = lastNames[Math.mod(agentCount, lastNames.size())];
        agentContact.AccountId = agency.Id;
        agentContact.Title = 'Insurance Agent';
        agentContact.Email = agentContact.FirstName.toLowerCase() + '.' + agentContact.LastName.toLowerCase() + '@' + agency.Name.replaceAll(' ', '').toLowerCase() + '.com';
        agentContact.Phone = '555-' + String.valueOf(2000 + agentCount).leftPad(4, '0');
        agentContacts.add(agentContact);
        agentCount++;
    }
}
insert agentContacts;
System.debug('Created ' + agentContacts.size() + ' agent contacts');

// Step 3: Create Producer records for each Agent Contact
System.debug('Creating Producer records...');
for(Contact agentContact : agentContacts) {
    Producer producer = new Producer();
    producer.AccountId = agentContact.AccountId;
    producer.ContactId = agentContact.Id;
    producer.Name = agentContact.FirstName + ' ' + agentContact.LastName;
    producer.Type = 'Partner Agent';
    producers.add(producer);
}
insert producers;
System.debug('Created ' + producers.size() + ' producers');

// Step 4: Create 5 Customer Person Accounts per Producer
System.debug('Creating Customer Person Accounts...');
String[] customerFirstNames = new String[]{'Alice', 'Bob', 'Carol', 'Daniel', 'Emma', 'Frank', 'Grace', 'Henry', 'Isabella', 'Jack', 'Katherine', 'Liam', 'Mia', 'Noah', 'Olivia', 'Peter', 'Quinn', 'Rachel', 'Samuel', 'Sophia'};
Integer customerCount = 0;

for(Producer producer : producers) {
    for(Integer k = 0; k < 5; k++) {
        Account customer = new Account();
        customer.FirstName = customerFirstNames[Math.mod(customerCount, customerFirstNames.size())];
        customer.LastName = lastNames[Math.mod(customerCount + 5, lastNames.size())];
        customer.RecordTypeId = personAccountRecordTypeId;
        customer.PersonEmail = customer.FirstName.toLowerCase() + '.' + customer.LastName.toLowerCase() + '@email.com';
        customer.PersonMobilePhone = '555-' + String.valueOf(3000 + customerCount).leftPad(4, '0');
        customer.PersonMailingStreet = String.valueOf(200 + customerCount*5) + ' Oak Avenue';
        customer.PersonMailingCity = (Math.mod(customerCount, 4) == 0) ? 'Boston' : 
                                     (Math.mod(customerCount, 4) == 1) ? 'Seattle' : 
                                     (Math.mod(customerCount, 4) == 2) ? 'Denver' : 'Miami';
        customer.PersonMailingState = (Math.mod(customerCount, 4) == 0) ? 'MA' : 
                                      (Math.mod(customerCount, 4) == 1) ? 'WA' : 
                                      (Math.mod(customerCount, 4) == 2) ? 'CO' : 'FL';
        customer.PersonMailingPostalCode = String.valueOf(20000 + customerCount*10);
        customers.add(customer);
        customerCount++;
    }
}
insert customers;
System.debug('Created ' + customers.size() + ' customers');

// Refresh customers to get PersonContactId
customers = [SELECT Id, PersonContactId, FirstName, LastName FROM Account WHERE Id IN :customers];

// Step 5: Create 1 Insurance Policy per Customer
System.debug('Creating Insurance Policies...');
String[] policyTypes = new String[]{'Life', 'Auto', 'Property', 'Health'};
String[] policyNames = new String[]{'Whole Life Coverage', 'Auto Protection Plan', 'Homeowners Insurance', 'Comprehensive Health'};
Integer policyCount = 0;
Integer producerIndex = 0;

for(Account customer : customers) {
    InsurancePolicy policy = new InsurancePolicy();
    policy.Name = policyNames[Math.mod(policyCount, policyTypes.size())] + ' - ' + customer.FirstName + ' ' + customer.LastName;
    policy.NameInsuredId = customer.Id;
    policy.PolicyType = policyTypes[Math.mod(policyCount, policyTypes.size())];
    policy.Status = 'In Force';
    policy.PremiumAmount = 1000 + (Math.mod(policyCount * 137, 4000));
    policy.PolicyTerm = 12;
    policy.TermType = 'Monthly';
    policy.EffectiveDate = Date.today().addMonths(-12);
    policy.ExpirationDate = Date.today().addMonths(12);
    policy.PolicyNumber = 'POL-' + String.valueOf(100000 + policyCount).leftPad(8, '0');
    policy.ProducerId = producers[producerIndex].Id;
    policies.add(policy);
    policyCount++;
    producerIndex++;
    if(producerIndex >= producers.size()) {
        producerIndex = 0;
    }
}
insert policies;
System.debug('Created ' + policies.size() + ' policies');

// Step 6: Create Policy Participants (Owner, Insured, Payor, Beneficiaries)
System.debug('Creating Policy Participants...');
String[] beneficiaryFirstNames = new String[]{'Alex', 'Bailey', 'Casey', 'Drew', 'Elliott', 'Finley', 'Harper', 'Jordan'};

for(Integer i = 0; i < policies.size(); i++) {
    InsurancePolicy policy = policies[i];
    Account customer = customers[i];
    
    // Owner
    InsurancePolicyParticipant owner = new InsurancePolicyParticipant();
    owner.PrimaryParticipantAccountId = customer.Id;
    owner.InsurancePolicyId = policy.Id;
    owner.Role = 'Owner';
    participants.add(owner);
    
    // Insured Party
    InsurancePolicyParticipant insured = new InsurancePolicyParticipant();
    insured.PrimaryParticipantAccountId = customer.Id;
    insured.InsurancePolicyId = policy.Id;
    insured.Role = 'Insured Party';
    participants.add(insured);
    
    // Payor
    InsurancePolicyParticipant payor = new InsurancePolicyParticipant();
    payor.PrimaryParticipantAccountId = customer.Id;
    payor.InsurancePolicyId = policy.Id;
    payor.Role = 'Payor';
    participants.add(payor);
    
    // Beneficiaries (1-4 per policy)
    Integer numBeneficiaries = 1 + Math.mod(i, 4); // 1 to 4 beneficiaries
    String[] relationshipTypes = new String[]{'Spouse', 'Child', 'Child', 'Parent'};
    
    for(Integer j = 0; j < numBeneficiaries; j++) {
        InsurancePolicyParticipant beneficiary = new InsurancePolicyParticipant();
        beneficiary.InsurancePolicyId = policy.Id;
        beneficiary.Role = 'Beneficiary';
        beneficiary.RelatedParticipantAccountId = customer.Id;
        // Set beneficiary percentage (equal distribution)
        Integer beneficiaryPercentage = Integer.valueOf(100 / numBeneficiaries);
        // Note: Beneficiary details would typically be separate Person Accounts
        // For demo purposes, we're creating placeholder participants
        participants.add(beneficiary);
    }
}
insert participants;
System.debug('Created ' + participants.size() + ' policy participants (including beneficiaries)');

System.debug('=== Data Generation Complete ===');
System.debug('Agencies: ' + agencies.size());
System.debug('Agent Contacts: ' + agentContacts.size());
System.debug('Producers: ' + producers.size());
System.debug('Customers: ' + customers.size());
System.debug('Policies: ' + policies.size());
System.debug('Policy Participants: ' + participants.size());
EOF

# Step 5: Execute the data generation script
echo "Generating demo data..."
sf apex run --file scripts/generate-insurance-data.apex --target-org FSCDEMO

# Step 6: Open the org
echo "Opening scratch org..."
sf org open --target-org FSCDEMO

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "Your FSC Insurance demo org is ready with:"
echo "  - 50 Insurance Agencies (Business Accounts)"
echo "  - 150 Agent Contacts (3 per agency)"
echo "  - 150 Producer records (1 per agent, Type='Partner Agent')"
echo "  - 750 Customers (Person Accounts, 5 per producer)"
echo "  - 750 Insurance Policies (1 per customer)"
echo "  - Policy Participants with Owner, Insured Party, Payor, and Beneficiaries"
echo ""
echo "The org will remain active for 30 days."
echo "=========================================="