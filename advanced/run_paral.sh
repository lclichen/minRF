export WORLD_SIZE=8 #$(nvidia-smi -L | wc -l)
# deepspeed --num_gpus $WORLD_SIZE main.py --learning_rate 1e-3 --save_dir "/home/host/simo/ckpts/{}"
# lrs=(1e-4 2e-4 4e-4 8e-4)
# widths=(64 128 256)
loglr=(-10 -9 -8 -7 -6 -5 -4 -3)
widths=(128)
gpuidx=(0 1 2 3 4 5 6 7)
masterports=(11600 11601 11602 11603 11604 11605 11606 11607)
for width in "${widths[@]}"; do
    for idx in "${gpuidx[@]}"; do
        loglr_idx=$((idx))
        loglrv=${loglr[$loglr_idx]}
        masterport=${masterports[$idx]}
        lr=$(python -c "print(2**$loglrv)")
        run_name="layer48_mup_lr_${lr}_width_${width}"
        echo "Running $run_name"
        deepspeed --master_port $masterport --include=localhost:$idx \
        main.py \
        --learning_rate $lr \
        --hidden_dim $width \
        --run_name $run_name \
        --save_dir "/home/host/simo/ckpts/${run_name}" \
        --num_train_epochs 2 \
        --n_layers 48 \
        --train_batch_size 128 \
        --per_device_train_batch_size 128 &
    done
        % ${#loglr[@]}
        wait
done