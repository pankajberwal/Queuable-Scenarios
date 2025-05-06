/*
* Synechron Scenario 1
* This LWC component retrieves related opportunities for a given record ID without using Apex.
* and filters them to show only those created in the last 90 days.
* It also formats the data for display and handles errors gracefully.
*
*/


import { LightningElement,wire, api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SynechronScenario1 extends LightningElement {
    @api recordId;

    relatedOpportunities;

    get haveOpportunities() {
        return this.relatedOpportunities && this.relatedOpportunities.length > 0;
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Opportunities',
        fields: [
            'Opportunity.Id',
            'Opportunity.Name',
            'Opportunity.StageName',
            'Opportunity.CloseDate',
            'Opportunity.Amount',
            'Opportunity.CreatedDate',
        ],
        sortby: 'CreatedDate DESC'
    })
    getRelatedOpportunities({data,error}) {
        if(data) {
            const ninetyDaysAgo = new Date();
            ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
            const isNinetyDaysAgo = ninetyDaysAgo.toISOString();
            if(data.records.length > 0) {
                this.relatedOpportunities = data.records.filter(record => record.fields.CreatedDate.value >= isNinetyDaysAgo)
                .map(record => {
                    const fieldEntries = Object.entries(record.fields).map(([key, value]) => {
                        return {
                            label: key,
                            value: value.value,
                            displayValue: value.displayValue,
                        };
                    });
                    return {
                        ...record,
                        fieldsList : fieldEntries,
                        highlightClass : record.fields.StageName.value === 'Closed Won' ? 'highlight closed-won':'highlight normal',
                    }
                });
                console.log('Filtered Opportunities:', this.relatedOpportunities);
            }
        } else if(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading related opportunities',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }
}