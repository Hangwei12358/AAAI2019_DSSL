
# dataset preprocessing
matlab -r 'try wisdm_transformed_1; catch; end; quit'
matlab -r 'try wisdm_transformed_2; catch; end; quit'
matlab -r 'try wisdm_transformed_3; catch; end; quit'

# pre-compute K 
matlab -r 'try semi_smm_1; catch; end; quit'
./z_2_semi_0.02.sh
matlab -r 'try semi_smm_2; catch; end; quit'

# training and testing
./semi_smm_3.sh

# performance calculation and analysis
matlab -r 'try calculateAll_semi; catch; end; quit'
matlab -r 'try getOptimalAll_semi; catch; end; quit'
matlab -r 'try RESULTS_ANALYZE_SEMI_large; catch; end; quit'


