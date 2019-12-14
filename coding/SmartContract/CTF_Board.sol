pragma solidity >=0.4.21 <0.6.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./safemath.sol";
import "./aion.sol";


contract Board_CTF is Ownable{
    Aion aion;

    struct Person{
        string name;
        string mssv;
        uint id;
        uint idTeam;
        uint rankOfPerson;
        uint scoreOfMember;
        bool haveTeam;
    }

    struct Team{
        uint id;
        string name;
        Person[] members;
        uint rankOfTeam;
        uint scoreOfTeam;
    }

    struct Competition{
        string nameOfCompetition;
        uint id;
        uint scoreOfCompetition;
        Team[] registrationTeam;
        uint startDay;
        uint endDay;
    }

    struct Board{
        uint week;
        uint time;
        Person[] personBoard;
        Team[] teamBoard;
    }

    Board[] public boards;
    Person[] public persons;
    Team[] public teams;
    Competition[] public competitions;


    mapping(address => uint) public addressOfPerson;
    mapping(address => Team) addressOfTeam;
    mapping(address => Competition) addressOfCompetition;
    mapping(address => address) personOfTeam;
    mapping(uint => uint) public weekPersonBoard;
    mapping(uint => uint) public weekTeamBoard;


    //------------------Person----------------------//
    event NewPerson(string name, string mssv);

    function createPerson(string memory _name, string memory _mssv) public {
        persons.length++;
        Person storage person = persons[persons.length - 1];
        person.name = _name;
        person.mssv = _mssv;
        person.id = persons.length - 1;
        person.rankOfPerson = 0;
        person.scoreOfMember = 0;
        person.haveTeam = false;

        addressOfPerson[msg.sender] = person.id;
        emit NewPerson(_name, _mssv);
    }


    //------------------Team----------------------//
    event NewTeam(string name);

    function createTeam(string memory _nameOfTeam) public payable{
        teams.length++;
        Team storage team = teams[teams.length - 1];
        team.name = _nameOfTeam;
        team.id = teams.length - 1;
        team.scoreOfTeam = persons[addressOfPerson[msg.sender]].scoreOfMember;
        team.members.push(persons[addressOfPerson[msg.sender]]);

        team.members[0].idTeam = team.id;
        team.members[0].haveTeam = true;

        persons[addressOfPerson[msg.sender]].haveTeam = true;
        persons[addressOfPerson[msg.sender]].idTeam = team.id;
        emit NewTeam(_nameOfTeam);
    }

    //----------------Competition-------------------------//
    event NewCompetition(string name);
    function createCompetition(string memory _nameOfCompetition, uint _scoreOfCompetition) public onlyOwner{
        competitions.length++;
        Competition storage competition = competitions[competitions.length - 1];
        competition.nameOfCompetition = _nameOfCompetition;
        competition.scoreOfCompetition = _scoreOfCompetition;
        competition.id = competitions.length - 1;
        competition.startDay = now + 7 days;
        competition.endDay = now + 8 days;
        emit NewCompetition(_nameOfCompetition);
    }

    //----------------------------------------------------------------------//
    /**
    *
    * Update rank and score of team and person
    *
    */
    function updateScoreOfPerson(uint _idPerson, uint _score) public onlyOwner{
        persons[_idPerson].scoreOfMember += _score;
        if(persons[_idPerson].haveTeam == true){
        teams[persons[_idPerson].idTeam].scoreOfTeam = teams[persons[_idPerson].idTeam].scoreOfTeam + _score;
        }

        /**
        *
        * Update rank of person
        *
        */
        Person[] memory boardPerson = persons;
        for(uint i = 0; i < boardPerson.length; i++){
            for(uint j = 0; j < boardPerson.length; j++){
                if(boardPerson[i].scoreOfMember < boardPerson[j].scoreOfMember){
                    Person memory person = boardPerson[i];
                    boardPerson[i] = boardPerson[j];
                    boardPerson[j] = person;
                }
            }
        }

        for(uint i = 0; i < boardPerson.length; i++){
            boardPerson[i].rankOfPerson = i + 1;
        }

        for(uint i = 0; i < boardPerson.length; i++){
            for(uint j = 0; j < persons.length; j++){
                if(boardPerson[i].id == persons[j].id){
                    persons[j].rankOfPerson = boardPerson[i].rankOfPerson;
                }
            }
        }

        /**
        *
        * Update rank of team
        *
        */
        Team[] memory boardTeam = teams;
        for(uint i = 0; i < boardTeam.length; i++){
            for(uint j = 0; j < boardTeam.length; j++){
                if(boardTeam[i].scoreOfTeam < boardTeam[j].scoreOfTeam){
                    Team memory team = boardTeam[i];
                    boardTeam[i] = boardTeam[j];
                    boardTeam[j] = team;
                }
            }
        }

        for(uint i = 0; i < boardTeam.length; i++){
            boardTeam[i].rankOfTeam = i + 1;
        }

        for(uint i = 0; i < boardTeam.length; i++){
            for(uint j = 0; j < teams.length; j++){
                if(boardTeam[i].id == teams[j].id){
                    teams[j].rankOfTeam = boardTeam[i].rankOfTeam;
                }
            }
        }
    }

    /**
    *
    * Update board
    *
    */
    function getBoardPersonNow() public view returns(Person[] memory){
        Person[] memory board = persons;
        for(uint i = 0; i < board.length; i++){
            for(uint j = 0; j < board.length; j++){
                if(board[i].scoreOfMember < board[j].scoreOfMember){
                    Person memory person = board[i];
                    board[i] = board[j];
                    board[j] = person;
                }
            }
        }

        return board;
    }

    function getBoardTeamNow() public view returns(Team[] memory){
        Team[] memory board = teams;
        for(uint i = 0; i < board.length; i++){
            for(uint j = 0; j < board.length; j++){
                if(board[i].scoreOfTeam < board[j].scoreOfTeam){
                    Team memory team = board[i];
                    board[i] = board[j];
                    board[j] = team;
                }
            }
        }

        return board;
    }

    function updateWeekBoard() public {
        boards.length++;
        Board storage _board = boards[boards.length - 1];
        _board.week = boards.length - 1;
        _board.time = now;

        _board.personBoard = persons;
        for(uint i = 0; i < _board.personBoard.length; i++){
            for(uint j = 0; j < _board.personBoard.length; j++){
                if(_board.personBoard[i].scoreOfMember < _board.personBoard[j].scoreOfMember){
                    Person memory person = _board.personBoard[i];
                    _board.personBoard[i] = _board.personBoard[j];
                    _board.personBoard[j] = person;
                }
            }
        }

        _board.teamBoard = teams;
        for(uint i = 0; i < _board.teamBoard.length; i++){
            for(uint j = 0; j < _board.teamBoard.length; j++){
                if(_board.teamBoard[i].scoreOfTeam < _board.teamBoard[j].scoreOfTeam){
                    Team storage team = _board.teamBoard[i];
                    _board.teamBoard[i] = _board.teamBoard[j];
                    _board.teamBoard[j] = team;
                }
            }
        }

        weekPersonBoard[_board.week] = now;
    }

    function updateBoard(address _addAion) public returns(uint){
        aion = Aion(_addAion);
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256('updateWeekBoard()')));
        aion.ScheduleCall( block.timestamp + 3 minutes, address(this), 0, 200000, 1e9, data, true);
        return(now);
    }

    /**
    *
    * Update member of team
    *
    */
    function deleteMember(Person memory _person, Person[] storage _arr) internal {
        for(uint i = 0; i < _arr.length; i++){
            if(_arr[i].id == _person.id){
                for(uint j = i; j < _arr.length - 1; j++){
                    _arr[j] = _arr[j + 1];
                }
                delete _arr[_arr.length - 1];
                _arr.length--;
            }
        }
    }

    function outTeam() public{
        persons[addressOfPerson[msg.sender]].haveTeam = false;
        deleteMember(persons[addressOfPerson[msg.sender]], teams[persons[addressOfPerson[msg.sender]].idTeam].members);
        persons[addressOfPerson[msg.sender]].idTeam = 10000000;
    }

    function joinTeam(uint _teamId) public{
        if(teams[_teamId].members.length < 4){
            uint id = teams[_teamId].members.push(persons[addressOfPerson[msg.sender]]) - 1;
            persons[addressOfPerson[msg.sender]].haveTeam = true;
            persons[addressOfPerson[msg.sender]].idTeam = teams[_teamId].id;

            teams[_teamId].members[id].haveTeam = true;
            teams[_teamId].members[id].idTeam = _teamId;
        }
    }

    /**
    *
    * Team and member join competition
    *
    */
    function joinCompatition(uint _idOfCompatition) public{
        competitions[_idOfCompatition].registrationTeam.push(teams[persons[addressOfPerson[msg.sender]].idTeam]);
    }


    //--------------get---------------------------------//
    function getNameOfPersons(uint _personId)public view returns(string memory){
        return persons[_personId].name;
    }

    function getMssvOfPerson(uint _personId) public view returns(string memory){
        return persons[_personId].mssv;
    }

    function getScoreOfPerson(uint _personId) public view returns(uint){
        return persons[_personId].scoreOfMember;
    }

    function getRankOfPerson(uint _personId) public view returns(uint){
        return persons[_personId].rankOfPerson;
    }

    function getHaveTeamOfPerson(uint _personId) public view returns(bool){
        return persons[_personId].haveTeam;
    }
    //------------------------set--------------------//

    function setNameOfPerson(string memory _name) public {
        persons[addressOfPerson[msg.sender]].name = _name;
    }

    function setMssvOfPerson(string memory _mssv) public {
        persons[addressOfPerson[msg.sender]].mssv = _mssv;
    }

    //function setHaveTeamOfPerson(bool _haveTeam) public {
    //    persons[addressOfPerson[msg.sender]].haveTeam = _haveTeam;
    //}

    //---------------------set------------------------//
    function setNameOfTeam(uint _teamId, string memory _name) public {
        teams[_teamId].name = _name;
    }


    //--------------------get------------------------//
    function getNameOfTeam(uint _teamId) public view returns(string memory){
        return teams[_teamId].name;
    }

    function getScoreOfTeam(uint _teamId) public view returns(uint){
        return teams[_teamId].scoreOfTeam;
    }

    function getRankOfTeam(uint _teamId) public view returns(uint){
        return teams[_teamId].rankOfTeam;
    }

    function getMembersOfTeam(uint _teamId) public view returns(Person[] memory){
        return teams[_teamId].members;
    }

    //-------------------set Competition---------------//
    function setNameOfCompetition(uint _competitionId, string memory _name) public onlyOwner{
        competitions[_competitionId].nameOfCompetition = _name;
    }

    function setScoreOfCompetition(uint _competitionId, uint _scoreOfCompetition) public onlyOwner{
        competitions[_competitionId].scoreOfCompetition = _scoreOfCompetition;
    }

    //------------------get Competition---------------//
    function getNameOfCompetition(uint _competitionId) public view returns(string memory){
        return competitions[_competitionId].nameOfCompetition;
    }

    function getScoreOfCompetition(uint _competitionId) public view returns(uint){
        return competitions[_competitionId].scoreOfCompetition;
    }

    function getRegistrationTeam(uint _competitionId) public view returns(Team[] memory){
        return competitions[_competitionId].registrationTeam;
    }
    //----------------------------------------------------//

    function getBoardPersonOfWeek(uint _week)public view returns(Person[] memory){
        return boards[_week].personBoard;
    }

    function getBoardTeamOfWeek(uint _week)public view returns(Person[] memory){
        return boards[_week].personBoard;
    }
}