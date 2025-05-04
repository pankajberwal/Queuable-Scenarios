import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchTransactions from '@salesforce/apex/TransactionController.fetchTransactions';

export default class AccountTransactionContainer extends LightningElement {
    accountNumber;

    handleAccountNumberChange(event) {
        this.accountNumber = event.detail.value;
        this.validateAccountNumber();
    }

    validateAccountNumber() {
        if(this.accountNumber.length > 10) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Account number cannot exceed 10 characters.',
                    variant: 'error',
                }),
            );
        }
    }

    handleFetchTransactions(event) {
        console.log('Fetching transactions for account number:', this.accountNumber);
        fetchTransactions({accountNumber : this.accountNumber})
        .then(transactions => {
            console.log('Transactions fetched:', transactions);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Transactions fetched successfully.',
                    variant: 'success',
                }),
            );
        }
        )
        .catch(error => {
            console.error('Error fetching transactions:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error fetching transactions.',
                    variant: 'error',
                }),
            );
        });
    }
    
}