# Return the top 5 results
    - faas-cli store list | head -n 5

# Filter the results for the word analysis
    - faas-cli store list | grep Analysis
    - faas-cli store deploy SentimentAnalysis

# You creat localy but
# you must buld/deploy/push the functions in the rpi environement
    1. FROM LOCAL: scp -r OpenFaas/* pirate@master:~/OpenFaas/
    2. ON THE MASTER: cd ~/OpenFaas/
    3. faas-cli up -f <FUNCTION>


### Note;
    - kubectl -n openfaas port-forward gateway-6b44db58dc-kqjpw 8080:8080