/**
 * Copyright (c) 2020-2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import { updateResources } from "@wso2is/admin.core.v1/api/bulk-operations";
import { AppState } from "@wso2is/admin.core.v1/store";
import { userstoresConfig } from "@wso2is/admin.extensions.v1/configs/userstores";
import { useGroupList } from "@wso2is/admin.groups.v1/api/groups";
import { GroupsInterface, GroupsMemberInterface } from "@wso2is/admin.groups.v1/models/groups";
import { APPLICATION_DOMAIN, INTERNAL_DOMAIN } from "@wso2is/admin.roles.v2/constants";
import { PRIMARY_USERSTORE } from "@wso2is/admin.userstores.v1/constants";
import {
    AlertInterface,
    AlertLevels,
    ProfileInfoInterface
} from "@wso2is/core/models";
import { addAlert } from "@wso2is/core/store";
import { StringUtils } from "@wso2is/core/utils";
import {
    ContentLoader,
    Heading,
    ItemTypeLabelPropsInterface,
    LinkButton,
    PrimaryButton,
    TransferComponent,
    TransferList,
    TransferListItem
} from "@wso2is/react-components";
import { AxiosError, AxiosRequestConfig } from "axios";
import escapeRegExp from "lodash-es/escapeRegExp";
import forEachRight from "lodash-es/forEachRight";
import isEmpty from "lodash-es/isEmpty";
import React, { FormEvent, FunctionComponent, ReactElement, useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useDispatch, useSelector } from "react-redux";
import { Dispatch } from "redux";
import {
    Grid,
    Modal
} from "semantic-ui-react";
import { UserGroupsListTable } from "./user-groups-list";

interface UserGroupsPropsInterface {
    /**
     * User profile
     */
    user: ProfileInfoInterface;
    /**
     * On alert fired callback.
     */
    onAlertFired: (alert: AlertInterface) => void;
    /**
     * Handle user update callback.
     */
    handleUserUpdate: (userId: string) => void;
    /**
     * Show if the user is read only.
     */
    isReadOnly?: boolean;
}

export const UserGroupsList: FunctionComponent<UserGroupsPropsInterface> = (
    props: UserGroupsPropsInterface
): ReactElement => {

    const {
        onAlertFired,
        user,
        handleUserUpdate,
        isReadOnly
    } = props;

    const primaryUserStoreDomainName: string = useSelector((state: AppState) =>
        state?.config?.ui?.primaryUserStoreDomainName);

    const { t } = useTranslation();

    const dispatch: Dispatch = useDispatch();

    const [ showAddNewRoleModal, setAddNewRoleModalView ] = useState(false);
    const [ groupList, setGroupList ] = useState<any>([]);
    const [ selectedGroupsList, setSelectedGroupList ] = useState([]);
    const [ initialGroupList, setInitialGroupList ] = useState([]);
    const [ primaryGroupsList, setPrimaryGroupsList ] = useState<Map<string, string>>(undefined);
    const [ isSelectAllGroupsChecked, setIsSelectAllGroupsChecked ] = useState(false);
    const [ isSubmitting, setIsSubmitting ] = useState<boolean>(false);
    const [ existingGroupList, setExistingGroupList ] = useState([]);

    const domain: string = user?.userName?.split("/")?.length > 1
        ? user.userName.split("/")[0]
        : userstoresConfig.primaryUserstoreName;

    const {
        data: originalGroupsList,
        error: groupsListFetchRequestError,
        isLoading: isGroupsListFetchRequestLoading,
        isValidating: isGroupsListFetchRequestValidating
    } = useGroupList(domain);

    const primaryGroups: GroupsInterface[] = useMemo(() => {
        if (originalGroupsList?.Resources) {
            return originalGroupsList.Resources;
        }
    }, [ originalGroupsList ]);

    const isLoading: boolean = useMemo(() => {
        return isGroupsListFetchRequestLoading || isGroupsListFetchRequestValidating;
    }, [ isGroupsListFetchRequestLoading, isGroupsListFetchRequestValidating ]);

    useEffect(() => {
        if (!(user)) {
            return;
        }
        mapUserGroups();
    }, []);

    /**
     * Show error if group list fetch request failed.
     */
    useEffect(() => {
        if (groupsListFetchRequestError) {
            if (groupsListFetchRequestError.response && groupsListFetchRequestError.response.data &&
                groupsListFetchRequestError.response.data.description) {
                dispatch(
                    addAlert({
                        description: groupsListFetchRequestError.response.data.description,
                        level: AlertLevels.ERROR,
                        message: t("console:manage.features.roles.edit.groups.notifications.fetchError.message")
                    })
                );

                return;
            }

            dispatch(
                addAlert({
                    description: t("console:manage.features.roles.edit.groups.notifications.fetchError.description"),
                    level: AlertLevels.ERROR,
                    message: t("console:manage.features.roles.edit.groups.notifications.fetchError.message")
                })
            );
        }
    }, [ groupsListFetchRequestError ]);

    /**
     * The following useEffect will be triggered when the
     * roles are updated.
     */
    useEffect(() => {
        if (!(user)) {
            return;
        }
        mapUserGroups();
    }, [ user ]);

    useEffect(() => {
        if (!(user.groups)) {
            return;
        }
        setInitialLists();
    }, [ user.groups && primaryGroups ]);


    const mapUserGroups = () => {
        const groupsMap: Map<string, string>  = new Map<string, string> ();

        if (user.groups && user.groups instanceof Array) {
            forEachRight (user.groups, (group: GroupsMemberInterface) => {
                const groupName: string[] = group?.display?.split("/");

                if (groupName[0] !== APPLICATION_DOMAIN && groupName[0] !== INTERNAL_DOMAIN) {
                    groupsMap.set(group.display, group.value);
                }
            });
            setPrimaryGroupsList(groupsMap);
        } else {
            setPrimaryGroupsList(undefined);
        }
    };

    /**
     * The following function enables the user to select all the roles at once.
     */
    const selectAllGroups = () => {
        if (!isSelectAllGroupsChecked) {
            setSelectedGroupList(groupList);
        } else {
            setSelectedGroupList([]);
        }
        setIsSelectAllGroupsChecked(!isSelectAllGroupsChecked);
    };

    /**
     * The following method handles the onChange event of the
     * checkbox field of an unassigned item.
     */
    const handleUnassignedItemCheckboxChange = (group: GroupsInterface) => {
        const checkedGroups: GroupsInterface[] = [ ...selectedGroupsList ];

        if (checkedGroups?.includes(group)) {
            checkedGroups.splice(checkedGroups.indexOf(group), 1);
            setSelectedGroupList(checkedGroups);
        } else {
            checkedGroups.push(group);
            setSelectedGroupList(checkedGroups);
        }
        setIsSelectAllGroupsChecked(checkedGroups.length === groupList.length);
    };

    const setInitialLists = () => {
        const groupListCopy: GroupsInterface[] = primaryGroups ? [ ...primaryGroups ] : [];
        const addedGroups: GroupsInterface[] = [];

        forEachRight(groupListCopy, (group: GroupsInterface) => {
            if (primaryGroupsList?.has(group.displayName)) {
                addedGroups.push(group);
            }
        });
        setSelectedGroupList(addedGroups);
        setExistingGroupList(addedGroups);
        setGroupList(groupListCopy);
        setInitialGroupList(groupListCopy);
        setIsSelectAllGroupsChecked(groupListCopy.length === addedGroups.length);
    };

    const handleOpenAddNewGroupModal = () => {
        setInitialLists();
        setAddNewRoleModalView(true);
    };

    const handleCloseAddNewGroupModal = () => {
        setIsSelectAllGroupsChecked(false);
        setAddNewRoleModalView(false);
    };

    const handleUnselectedListSearch = (e: FormEvent<HTMLInputElement>, { value }: { value: string}) => {
        let isMatch: boolean = false;
        const filteredGroupList: GroupsInterface[] = [];

        if (!isEmpty(value)) {
            const re: RegExp = new RegExp(escapeRegExp(value), "i");

            groupList && groupList.map((role: GroupsInterface) => {
                isMatch = re.test(role.displayName);
                if (isMatch) {
                    filteredGroupList.push(role);
                    setGroupList(filteredGroupList);
                }
            });
        } else {
            setGroupList(initialGroupList);
        }
    };

    /**
     * This function handles assigning the roles to the user.
     *
     * @param user - User object
     * @param groups - Assigned groups
     */
    const updateUserGroup = (user: any, groups: any) => {
        const groupIds: string[] = [];

        groups.map((group: GroupsInterface) => {
            groupIds.push(group.id);
        });

        const bulkData: any = {
            Operations: [],
            schemas: [ "urn:ietf:params:scim:api:messages:2.0:BulkRequest" ]
        };

        let removeOperation: AxiosRequestConfig = {
            data: {
                "Operations": [ {
                    "op": "remove",
                    "path": "members[display eq" + " " + user.userName + "]"
                } ]
            },
            method: "PATCH"
        };

        let addOperation: AxiosRequestConfig = {
            data: {
                "Operations": [ {
                    "op": "add",
                    "value": {
                        "members": [ {
                            "display": user.userName,
                            "value": user.id
                        } ]
                    }
                } ]
            },
            method: "PATCH"
        };

        const removeOperations: AxiosRequestConfig[] = [];
        const addOperations: AxiosRequestConfig[] = [];
        let removedIds: string[] = [];

        if (primaryGroupsList) {
            removedIds = [ ...primaryGroupsList.values() ];
        }

        if (groupIds?.length > 0) {
            groupIds.map((groupId: string) => {
                if (removedIds?.includes(groupId)) {
                    removedIds.splice(removedIds.indexOf(groupId), 1);
                }
            });
        }

        if (removedIds && removedIds.length > 0) {
            removedIds.map((id: string) => {
                removeOperation = {
                    ...removeOperation,
                    ...{ path: "/Groups/" + id }
                };
                removeOperations.push(removeOperation);
            });

            removeOperations.map((operation: AxiosRequestConfig) => {
                bulkData.Operations.push(operation);
            });
        }

        if (groupIds && groupIds?.length > 0) {
            groupIds.map((id: string) => {
                if (!existingGroupList.find((existingGroup: GroupsInterface) => existingGroup.id === id)) {
                    addOperation = {
                        ...addOperation,
                        ...{ path: "/Groups/" + id }
                    };
                    addOperations.push(addOperation);
                }
            });

            addOperations.map((operation: AxiosRequestConfig) => {
                bulkData.Operations.push(operation);
            });
        }

        setIsSubmitting(true);

        updateResources(bulkData)
            .then(() => {
                onAlertFired({
                    description: t(
                        "user:updateUser.groups.notifications.updateUserGroups." +
                        "success.description"
                    ),
                    level: AlertLevels.SUCCESS,
                    message: t(
                        "user:updateUser.groups.notifications.updateUserGroups." +
                        "success.message"
                    )
                });
                handleCloseAddNewGroupModal();
                handleUserUpdate(user.id);
            })
            .catch((error: AxiosError) => {
                if (error?.response?.status === 404) {
                    return;
                }

                if (error?.response && error?.response?.data && error?.response?.data?.description) {
                    onAlertFired({
                        description: error.response?.data?.description,
                        level: AlertLevels.ERROR,
                        message: t(
                            "user:updateUser.groups.notifications.updateUserGroups." +
                            "error.message"
                        )
                    });

                    return;
                }

                onAlertFired({
                    description: t(
                        "user:updateUser.groups.notifications.updateUserGroups." +
                        "genericError.description"
                    ),
                    level: AlertLevels.ERROR,
                    message: t(
                        "user:updateUser.groups.notifications.updateUserGroups." +
                        "genericError.message"
                    )
                });
            })
            .finally(() => {
                setIsSubmitting(false);
            });
    };

    const resolveListItemLabel = (displayName: string): ItemTypeLabelPropsInterface => {
        const userGroup: string[]  = displayName?.split("/");

        let item: ItemTypeLabelPropsInterface = {
            labelColor: "olive",
            labelText: StringUtils.isEqualCaseInsensitive(primaryUserStoreDomainName, PRIMARY_USERSTORE)
                ? t("console:manage.features.users.userstores.userstoreOptions.primary")
                : primaryUserStoreDomainName
        };

        if (userGroup[0] !== APPLICATION_DOMAIN &&
            userGroup[0] !== INTERNAL_DOMAIN) {
            if (userGroup?.length > 1) {
                item = {
                    ...item,
                    labelText: userGroup[0]
                };
            }
        }

        return item;
    };

    const resolveListItem = (displayName: string): string => {
        const userGroup: string[]  = displayName?.split("/");

        if (userGroup?.length !== 1) {
            displayName = userGroup[1];
        }

        return displayName;
    };

    const addNewGroupModal = () => (
        <Modal
            data-testid="user-mgt-update-groups-modal"
            open={ showAddNewRoleModal }
            size="small"
            className="user-roles"
        >
            <Modal.Header>
                { t("user:updateUser.groups.addGroupsModal.heading") }
                <Heading subHeading ellipsis as="h6">
                    { t("user:updateUser.groups.addGroupsModal.subHeading") }
                </Heading>
            </Modal.Header>
            <Modal.Content image>
                { !isLoading ? (
                    <TransferComponent
                        selectionComponent
                        searchPlaceholder={ t("transferList:searchPlaceholder",
                            { type: "Groups" }) }
                        handleUnelectedListSearch={ handleUnselectedListSearch }
                        data-testid="user-mgt-update-groups-modal"
                    >
                        <TransferList
                            isListEmpty={ !(groupList.length > 0) }
                            listType="unselected"
                            listHeaders={ [
                                t("transferList:list.headers.0"),
                                t("transferList:list.headers.1")
                            ] }
                            handleHeaderCheckboxChange={ selectAllGroups }
                            isHeaderCheckboxChecked={ isSelectAllGroupsChecked }
                            emptyPlaceholderContent={ t("transferList:list." +
                                    "emptyPlaceholders.users.roles.unselected", { type: "groups" }) }
                            data-testid="user-mgt-update-groups-modal-unselected-groups-select-all-checkbox"
                            emptyPlaceholderDefaultContent={ t("transferList:list."
                                + "emptyPlaceholders.default") }
                        >
                            {
                                groupList?.map((group: GroupsInterface, index: number)=> {
                                    return (
                                        <TransferListItem
                                            handleItemChange={
                                                () => handleUnassignedItemCheckboxChange(group)
                                            }
                                            key={ index }
                                            listItem={ resolveListItem(group?.displayName) }
                                            listItemId={ group?.id }
                                            listItemIndex={ index }
                                            listItemTypeLabel={ resolveListItemLabel(group?.displayName) }
                                            isItemChecked={ selectedGroupsList.includes(group) }
                                            showSecondaryActions={ false }
                                            data-testid="user-mgt-update-groups-modal-unselected-groups"
                                        />
                                    );
                                })
                            }
                        </TransferList>
                    </TransferComponent>
                ) : <ContentLoader/> }
            </Modal.Content>
            <Modal.Actions>
                <Grid>
                    <Grid.Row columns={ 2 }>
                        <Grid.Column mobile={ 8 } tablet={ 8 } computer={ 8 }>
                            <LinkButton
                                data-testid="user-mgt-update-groups-modal-cancel-button"
                                floated="left"
                                onClick={ handleCloseAddNewGroupModal }
                            >
                                { t("common:cancel") }
                            </LinkButton>
                        </Grid.Column>
                        <Grid.Column mobile={ 8 } tablet={ 8 } computer={ 8 }>
                            <PrimaryButton
                                data-testid="user-mgt-update-groups-modal-save-button"
                                floated="right"
                                loading={ isSubmitting }
                                disabled={ isSubmitting }
                                onClick={ () => updateUserGroup(user, selectedGroupsList) }
                            >
                                { t("common:save") }
                            </PrimaryButton>
                        </Grid.Column>
                    </Grid.Row>
                </Grid>
            </Modal.Actions>
        </Modal>
    );

    return (
        <>
            <UserGroupsListTable
                handleOpenAddNewGroupModal={ handleOpenAddNewGroupModal }
                handleUserUpdate={ handleUserUpdate }
                isLoading={ isLoading }
                isReadOnly={ isReadOnly }
                user={ user }
            />
            { addNewGroupModal() }
        </>
    );
};
