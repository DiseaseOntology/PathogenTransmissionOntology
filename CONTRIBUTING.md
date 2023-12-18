# Pathogen Transmission Ontology Contributor Guidelines

We value every :sparkles:contribution:sparkles:.&nbsp;&nbsp;&nbsp; Thank you! :clap:

## Table of Contents

1. [Introduction](#1-introduction)
2. [Contributing Guidelines: Issues Preferred](#2-contributing-guidelines-issues-preferred)  
3. [What to Expect from Us](#3-what-to-expect-from-us)
4. [Contact Information](#4-contact-information)
5. _[Additional Information](#5-additional-information)_

## 1. Introduction

This document describes how to make contributions and requests related to data in the Pathogen Transmission Ontology (TRANS). We want it to be _easy_ :muscle:, for both beginners and experts. All suggestions for improvement and requests for new data are welcome. The inclusion of supporting documentation and author ORCiD IDs for attribution, are also highly appreciated :pray:.

When contributing, please adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

## 2. Contributing Guidelines: Issues Preferred

We strongly encourage contributors to use GitHub issues _instead of pull requests_ to propose and discuss changes. Using issues allows for collaborative discussion, consensus building, and thorough review before they are implemented.

Pull requests (PRs) are generally harder to create and harder to review with current ontology editing tools, requiring more effort on your part and ours.

Issue templates have not been created for this ontology, since pathogen transmission processes are fairly static and few in number. If you have a request please open a [blank issue](https://github.com/DiseaseOntology/PathogenTransmissionOntology/issues/new) and include as many details as possible. Alternatively, feel free to [contact us](#4-contact-information) directly. Please include "Pathogen Transmission Ontology" or "TRANS" in the subject line or at the beginning of the communication.

:clock10: Your time is valuable, we won't judge the format of your contributions. :point_up: _Remember, something is always better than nothing_. Please include your ORCiD ID with your request, so that we can recognize your contribution on our contributors page.

## 3. What to Expect from Us

Always expect a cordial and timely response. When requests are straightforward and accepted, expect the issue to be implemented and closed with little, if any, additional back and forth comments. When issues are complex or expanded upon, we may provide or request further information on the issue to support or outline decision-making. **Discussions are always welcome**, it aids curation and decision-making, but _don't feel obligated to reply_. If for some reason changes suggested or requested will _not_ be implemented, we will explain why in a comment posted to the issue. If you disagree or just feel a desire to comment further, please do!

## 4. Contact Information

If you have questions or need further assistance, please feel free to reach out to us:

- By email: [Lynn](mailto:lschriml@som.umaryland.edu), [Allen](mailto:allenbaron@som.umaryland.edu), or [Claudia](mailto:csbjohnson@som.umaryland.edu)
- Using the contact form at [disease-ontology.org](https://disease-ontology.org/outreach/contact-us)
- Via the Human Disease Ontology public Slack channel ([join](https://join.slack.com/t/humandiseaseontology/shared_invite/zt-25vj64myc-h~DOMTJ_iNyyZnPhlDmJFA))
- Via Twitter ([@diseaseontology](https://twitter.com/diseaseontology))
- Via Facebook ([Disease Ontology](https://www.facebook.com/diseaseontology))

Thank you for your interest in contributing to the Pathogen Transmission Ontology. Your contributions play a vital role in maintaining this valuable resource for the scientific and medical community.

---

## 5. Additional Information

For those new to the Pathogen Transmission Ontology, or just wishing to better understand how it's organized or what's in it :wink:.

### Data in the Ontology

- Transmission processes are organized hierarchically in a [directed acyclic graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph) providing a conceptual representation of the relatedness of pathogen transmission processes.
  
- In the Pathogen Transmission Ontology, each TRANS record includes:
  - **Uniform Resource Identifier (URI)**: A persistent, web-accessible URL and ID (example: `http://purl.obolibrary.org/obo/TRANS_0000000`).
  - **label**: The current, active transmission process name (example: 'direct transmission').
  - **ID**: A short version of the URI using the approved, [OBO Foundry](https://obofoundry.org/ontology/trans.html) prefix 'TRANS' (example: TRANS:0000001).
  - **OBO namespace**: The namespace assigned to TRANS by the OBO Foundry ('transmission_process').
  - **parent/superclass**: One or more curator-asserted, direct process-to-process relationship(s) using `rdfs:subClassOf` in OWL or `is_a` in OBO files (example: the parent of [direct transmission](http://www.ebi.ac.uk/ols4/ontologies/trans/classes/http%253A%252F%252Fpurl.obolibrary.org%252Fobo%252FTRANS_0000001) is 'transmission process').
  - **definition**: A human-readable text definition written by a curator. All transmission processes have textual definitions and all definitions have supporting sources (specified as xrefs).
- Additional data which may be available for a transmission process, includes:
  - **synonym(s)**: Alternate names for a transmission process. These include historical and alternate names or acronyms, and may be exact, narrow, broad, or related in nature, denoted by [oboInOwl](https://github.com/geneontology/go-ontology/blob/master/contrib/oboInOwl.obo) annotations.
  - **deprecated**: A boolean utilized to indicate whether a transmission process has been deprecated, or no longer active. Only present on obsoleted transmission process terms. These terms are included in the TRANS ontology files, but are not usually shown in ontology term browsers.

### Pathogen Transmission Ontology Webpage

The primary webpage for the Pathogen Transmission Ontology is currently https://disease-ontology.org/resources/pathogen-transmission-ontology.