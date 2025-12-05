# Mission: SECURITY 🔒
## Security Audit, Assessment, and Remediation

**Mission Code**: SECURITY  
**Estimated Duration**: 4-6 hours  
**Complexity**: High  
**Squad Required**: Architect, Developer, Tester

## Mission Briefing

Conduct comprehensive security assessment and implement protective measures to safeguard systems, data, and users. Transform vulnerable systems into secure, resilient solutions that protect against modern threats.

## Required Inputs

1. **System Scope** (required) - Applications, infrastructure, or components to audit
2. **Security Requirements** (optional) - Compliance standards, security policies
3. **Threat Model** (optional) - Known threats or security concerns

## Mission Phases

### ⛔ PHASE GATE PROTOCOL [APPLIES TO ALL PHASE TRANSITIONS]

**Before starting ANY phase after Phase 1**, the coordinator MUST verify the previous phase passed its gate:
- ALL tasks from previous phase marked [x] with timestamps
- Phase completion entry in progress.md
- handoff-notes.md updated with current state
- agent-context.md has findings merged

**See `/coord` command for full PHASE GATE ENFORCEMENT details.**

---

### Phase 1: Security Assessment and Threat Modeling (60-90 minutes)
**Lead**: @architect  
**Support**: @developer  
**Objective**: Identify security vulnerabilities and potential attack vectors

**Tasks**:
- Map system architecture and data flows
- Identify sensitive data and critical assets
- Create threat model and attack vectors
- Review authentication and authorization mechanisms
- Assess network security and access controls

**Success Criteria**:
- Threat model documented
- Attack vectors identified
- Critical assets mapped
- Security baseline established

### Phase 2: Code Security Review (90-120 minutes)
**Lead**: @developer  
**Support**: @architect  
**Objective**: Identify security vulnerabilities in application code

**Tasks**:
- Review code for common security vulnerabilities (OWASP Top 10)
- Check for SQL injection, XSS, and CSRF vulnerabilities
- Assess input validation and output encoding
- Review authentication and session management
- Analyze access control and authorization logic

**Success Criteria**:
- Code vulnerabilities identified
- Security issues categorized by severity
- Remediation plan created
- Secure coding practices validated

### Phase 3: Infrastructure Security Assessment (75-90 minutes)
**Lead**: @architect  
**Support**: @operator  
**Objective**: Evaluate infrastructure security configuration

**Tasks**:
- Review server and network configurations
- Assess firewall rules and network segmentation
- Check SSL/TLS configurations and certificates
- Review access controls and user permissions
- Evaluate backup and disaster recovery security

**Success Criteria**:
- Infrastructure vulnerabilities identified
- Network security validated
- Access controls reviewed
- Security configurations documented

### Phase 4: Data Security and Privacy Review (60-75 minutes)
**Lead**: @developer  
**Support**: @architect  
**Objective**: Ensure data protection and privacy compliance

**Tasks**:
- Review data encryption at rest and in transit
- Assess data access controls and audit logging
- Check compliance with data protection regulations (GDPR, CCPA)
- Review data retention and deletion policies
- Validate sensitive data handling procedures

**Success Criteria**:
- Data encryption validated
- Privacy compliance verified
- Data handling procedures reviewed
- Audit logging confirmed

### Phase 5: Security Testing and Validation (90-120 minutes)
**Lead**: @tester  
**Support**: @developer  
**Objective**: Test security controls and validate protections

**Tasks**:
- Perform penetration testing on critical components
- Test authentication and authorization controls
- Validate input validation and sanitization
- Test for common web application vulnerabilities
- Verify security configurations and controls

**Success Criteria**:
- Penetration testing completed
- Security controls validated
- Vulnerabilities confirmed and documented
- Security test results analyzed

### Phase 6: Remediation and Hardening (90-150 minutes)
**Lead**: @developer  
**Support**: @architect  
**Objective**: Fix vulnerabilities and implement security improvements

**Tasks**:
- Fix identified security vulnerabilities
- Implement additional security controls
- Update security configurations and policies
- Add security monitoring and alerting
- Document security improvements and procedures

**Success Criteria**:
- Critical vulnerabilities fixed
- Security controls implemented
- Configurations hardened
- Monitoring established

## Security Assessment Areas

### Application Security
- **Authentication**: Multi-factor authentication, password policies
- **Authorization**: Role-based access control, permission management
- **Input Validation**: SQL injection, XSS prevention
- **Session Management**: Secure session handling, timeout policies

### Infrastructure Security
- **Network Security**: Firewalls, VPNs, network segmentation
- **Server Security**: OS hardening, patch management
- **Cloud Security**: IAM policies, resource configurations
- **Container Security**: Image scanning, runtime protection

### Data Security
- **Encryption**: Data at rest and in transit encryption
- **Access Controls**: Data access logging and monitoring
- **Privacy**: PII protection, data anonymization
- **Compliance**: GDPR, HIPAA, PCI DSS requirements

### Operational Security
- **Monitoring**: Security event monitoring and SIEM
- **Incident Response**: Breach response procedures
- **Backup Security**: Secure backup and recovery
- **Access Management**: User provisioning and deprovisioning

## Common Vulnerabilities

### OWASP Top 10 Web Application Risks
1. **Injection**: SQL, NoSQL, OS command injection
2. **Broken Authentication**: Session management flaws
3. **Sensitive Data Exposure**: Inadequate protection
4. **XML External Entities (XXE)**: XML processor vulnerabilities
5. **Broken Access Control**: Authorization bypass
6. **Security Misconfiguration**: Default/weak configurations
7. **Cross-Site Scripting (XSS)**: Reflected, stored, DOM-based
8. **Insecure Deserialization**: Object injection attacks
9. **Components with Known Vulnerabilities**: Outdated libraries
10. **Insufficient Logging & Monitoring**: Detection failures

### Infrastructure Vulnerabilities
- **Unpatched Systems**: Missing security updates
- **Weak Passwords**: Default or weak credentials
- **Open Ports**: Unnecessary exposed services
- **Misconfigured Services**: Insecure default settings

## Security Controls Implementation

### Authentication Controls
- **Multi-Factor Authentication**: TOTP, SMS, hardware tokens
- **Password Policies**: Complexity, rotation, history
- **Account Lockout**: Brute force protection
- **Single Sign-On**: Centralized authentication

### Authorization Controls
- **Role-Based Access Control**: Granular permissions
- **Principle of Least Privilege**: Minimal required access
- **Access Reviews**: Regular permission audits
- **Segregation of Duties**: Critical operation separation

### Data Protection Controls
- **Encryption**: AES-256, TLS 1.3, proper key management
- **Data Loss Prevention**: Sensitive data monitoring
- **Anonymization**: PII removal and pseudonymization
- **Access Logging**: Comprehensive audit trails

### Network Security Controls
- **Firewalls**: Application and network firewalls
- **Network Segmentation**: DMZ, VLANs, micro-segmentation
- **Intrusion Detection**: Network and host-based IDS
- **VPN**: Secure remote access

## Compliance Frameworks

### GDPR (General Data Protection Regulation)
- **Data Protection**: Privacy by design, consent management
- **Rights**: Data subject rights, portability, erasure
- **Breach Notification**: 72-hour reporting requirement
- **Data Processing**: Lawful basis, data minimization

### PCI DSS (Payment Card Industry)
- **Cardholder Data**: Protection and encryption
- **Network Security**: Secure configurations, monitoring
- **Access Control**: Restricted access, authentication
- **Testing**: Regular security testing and monitoring

### HIPAA (Health Insurance Portability)
- **PHI Protection**: Physical and electronic safeguards
- **Access Controls**: Minimum necessary access
- **Audit Controls**: Activity monitoring and logging
- **Data Integrity**: Alteration and destruction protection

### SOC 2 (Service Organization Control)
- **Security**: Access controls, logical security
- **Availability**: System uptime and performance
- **Processing Integrity**: Accurate, timely processing
- **Confidentiality**: Information protection
- **Privacy**: Personal information handling

## Security Testing Methods

### Static Analysis
- **Code Scanning**: Automated vulnerability detection
- **Configuration Review**: Security setting analysis
- **Dependency Scanning**: Third-party vulnerability assessment
- **Architecture Review**: Design security assessment

### Dynamic Analysis
- **Penetration Testing**: Simulated attacks
- **Vulnerability Scanning**: Network and application scanning
- **Web Application Testing**: OWASP testing methodology
- **API Testing**: REST/GraphQL security testing

### Manual Testing
- **Code Review**: Expert security code analysis
- **Configuration Audit**: Manual security verification
- **Social Engineering**: Human factor testing
- **Physical Security**: On-site security assessment

## Monitoring and Incident Response

### Security Monitoring
- **SIEM**: Security Information and Event Management
- **Log Analysis**: Centralized log monitoring
- **Anomaly Detection**: Behavioral analysis
- **Threat Intelligence**: External threat feeds

### Incident Response
- **Detection**: Security event identification
- **Analysis**: Incident impact assessment
- **Containment**: Threat isolation procedures
- **Recovery**: System restoration processes
- **Lessons Learned**: Post-incident improvement

## Success Metrics

### Security Metrics
- **Vulnerability Count**: Reduced critical/high vulnerabilities
- **Patch Time**: Mean time to patch vulnerabilities
- **Incident Response**: Time to detect and respond
- **Compliance Score**: Framework compliance percentage

### Business Metrics
- **Risk Reduction**: Quantified risk improvement
- **Compliance Status**: Audit and certification results
- **Incident Cost**: Reduced security incident costs
- **User Trust**: Customer confidence improvements

## Tools and Technologies

### Security Scanning
- **SAST**: SonarQube, Checkmarx, Veracode
- **DAST**: OWASP ZAP, Burp Suite, Nessus
- **Container**: Twistlock, Aqua Security, Clair
- **Cloud**: AWS Security Hub, Azure Security Center

### Monitoring and SIEM
- **SIEM**: Splunk, IBM QRadar, ArcSight
- **Log Management**: ELK Stack, Sumo Logic
- **Network Monitoring**: Wireshark, Nagios
- **Cloud Monitoring**: CloudTrail, Azure Monitor

## Integration Points

- **Follows**: BUILD, ARCHITECTURE, DEPLOYMENT missions
- **Enables**: Compliance, risk reduction, trust
- **Coordinates with**: Legal, compliance, operations teams
- **Requires**: System access, security tools, expertise

---

**Mission Command**: `/coord security [system-scope] [security-requirements] [threat-model]`

*"Security is not a product, but a process of continuous vigilance."*

---

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md
2. Archive current handoff-notes.md to `archives/handoffs/milestone-X/`
3. Clean agent-context.md (retain essentials, archive historical details)
4. Create fresh handoff-notes.md for next milestone
5. Update project-plan.md with next milestone tasks

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`
3. Update CLAUDE.md with system-level learnings
4. Archive all tracking files (project-plan.md, progress.md, etc.)
5. Prepare fresh start for next mission

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures.