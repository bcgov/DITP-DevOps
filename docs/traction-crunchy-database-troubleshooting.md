# Traction - Crunchy Database Troubleshooting



## Database downtime caused by depletion of storage capacity

CrunchyDB Postgres Cluster has a mechanism to allow some downtime of its backup repo. When WAL can not be pushed to the
repo it begins to accumulate on the local PVC. Thus, when `repo1` runs out of space and this does not get addressed, the
`ha` pods begin to fill up on local storage. Which results in complete database shutdown when both `ha` pods run out of space.


### Steps to recover the database when both, repo and local pvc are full

1. Recover some space on the `repo` pvc
   - Shell into `repo1` pod, and delete several of the oldest backups leaving more recent backups in place. (traction-database-repo-host-0)
   ```shell
    sh-4.4$ df -h
    Filesystem                                                                                             Size  Used Avail Use% Mounted on
    overlay                                                                                                 10G  8.0K   10G   1% /
    tmpfs                                                                                                   64M     0   64M   0% /dev
    tmpfs                                                                                                  126G     0  126G   0% /sys/fs/cgroup
    shm                                                                                                     64M     0   64M   0% /dev/shm
    tmpfs                                                                                                   51G  113M   51G   1% /etc/passwd
    /dev/sdb4                                                                                              745G  503G  242G  68% /tmp
    192.168.102.124:/trident_qtree_pool_backup_XOOPLIWNHW/backup_pvc_5f6f0c2a_63cd_4add_b1d2_d53edbd27358   28G   28G     0 100% /pgbackrest/repo1
    tmpfs                                                                                                  2.0G  8.0K  2.0G   1% /etc/pgbackrest/server
    tmpfs                                                                                                  2.0G   24K  2.0G   1% /etc/pgbackrest/conf.d
    tmpfs                                                                                                  126G     0  126G   0% /proc/acpi
    tmpfs                                                                                                  126G     0  126G   0% /proc/scsi
    tmpfs                                                                                                  126G     0  126G   0% /sys/firmware
    sh-4.4$ cd /pgbackrest/repo1/backup/db
    sh-4.4$ ls
    ...redacted...
    sh-4.4$ rm -rf 20240919-*
    sh-4.4$ rm -rf 20240920-*
    sh-4.4$ rm -rf 20240921-*
    sh-4.4$ rm -rf 20240922-*
    sh-4.4$ rm -rf 20240923-*
    sh-4.4$ rm -rf 20240924-*
    sh-4.4$ df -h
    Filesystem                                                                                             Size  Used Avail Use% Mounted on
    overlay                                                                                                 10G  8.0K   10G   1% /
    tmpfs                                                                                                   64M     0   64M   0% /dev
    tmpfs                                                                                                  126G     0  126G   0% /sys/fs/cgroup
    shm                                                                                                     64M     0   64M   0% /dev/shm
    tmpfs                                                                                                   51G  113M   51G   1% /etc/passwd
    /dev/sdb4                                                                                              745G  503G  242G  68% /tmp
    192.168.102.124:/trident_qtree_pool_backup_XOOPLIWNHW/backup_pvc_5f6f0c2a_63cd_4add_b1d2_d53edbd27358   28G  3.3G   25G  12% /pgbackrest/repo1
    tmpfs                                                                                                  2.0G  8.0K  2.0G   1% /etc/pgbackrest/server
    tmpfs                                                                                                  2.0G   24K  2.0G   1% /etc/pgbackrest/conf.d
    tmpfs                                                                                                  126G     0  126G   0% /proc/acpi
    tmpfs                                                                                                  126G     0  126G   0% /proc/scsi
    tmpfs                                                                                                  126G     0  126G   0% /sys/firmware
   ```

2. Allow the database pods to push its WAL to the repo

    If any of the database pods' own local storage is full, they will not be able to recover on their own. Even with space recovered on the Repo pod, the database pod requires local storage to write additional data before it's able to push local WAL to the repo and recover. We must temporarilty increase its local storage to allow it to recover on its own.

    - Modify the database (`ha`) pod's PVC to increase the capacity. For example from `13Gi` to `14Gi`.
      ```shell
      $ k get pvc -l postgres-operator.crunchydata.com/cluster=traction-database
      NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
      traction-database-ha-2fxn-pgdata   Bound    pvc-48a501d4-c9c8-434e-888c-017c06c7d0c6   13Gi       RWO            netapp-block-standard   101d
      traction-database-ha-7vph-pgdata   Bound    pvc-2d4c7208-8410-452e-b550-ff684f6c98d0   13Gi       RWO            netapp-block-standard   60m
      traction-database-pgadmin          Bound    pvc-120e7d4f-69b7-4d4e-8f6d-dcbbe5476b47   1Gi        RWO            netapp-file-standard    101d
      traction-database-repo1            Bound    pvc-5f6f0c2a-63cd-4add-b1d2-d53edbd27358   28Gi       RWO            netapp-file-backup      101d
      $ k edit pvc/traction-database-ha-7vph-pgdata
      ```
      ```yaml
      ...
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
      -      storage: 13Gi
      +      storage: 14Gi
      ...
      ```
    - Restart the database pod
      ```shell
      $ k get pods -l postgres-operator.crunchydata.com/cluster=traction-database
      NAME                                           READY   STATUS      RESTARTS   AGE
      traction-database-ha-2fxn-0                    5/5     Running     0          3d22h
      traction-database-ha-7vph-0                    5/5     Running     0          66m
      traction-database-pgadmin-0                    1/1     Running     0          10d
      traction-database-pgbouncer-588578b8d7-dl5zq   2/2     Running     0          32d
      traction-database-repo-host-0                  2/2     Running     0          96m
      ...
      $ k delete pod/traction-database-ha-7vph-0
      ```
    - Wait for the pod to push its local WAL to the repo. When the `pgdata` most of the pvc is recovered, and usage is stabilized around 1-1.18 GiB, it is now safe to re-create the PVC with the intended `13Gi` capacity, if desired.
#### 3. (Optional) Restore the PVC to original capacity
   - Mark the `pgdata` pvc for deletion (Delete the PVC, it won't be deleted until it is unmounted). Make sure it is the correct PVC by matching the random characters with the pod name.
   - Delete the `ha` pod. (Pod and PVC name's random characters shouuld match)
#### 3. Adjust Crunchy Postgres Cluster configuration as needed
   
    Re-evaluate the database usage and backup requirements.
