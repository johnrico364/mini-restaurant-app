import { useReservations } from "../hooks/useReservations";

interface ReservationTableProps {
  customerName: string;
  tableNumber: number;
  date: string;
  time: string;
  partySize: number;
  status: string;
  specialRequests: string;
}

export const ReservationTable = () => {
  const { data: reservations, isLoading } = useReservations();

  if (isLoading) {
    return (
      <div className="text-[1.8rem] font-bold">
        Loading reservations data please wait...{" "}
      </div>
    );
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <div className="mt-6 text-[1.5rem] font-semibold text-[#3396D3]">
          Reservations
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="table">
          {/* head */}
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Table</th>
              <th>Date</th>
              <th>Time</th>
              <th>Party size</th>
              <th>Request</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {reservations?.map(
              (reservations: ReservationTableProps, i: number) => {
                return (
                  <tr key={i}>
                    <th>{i + 1}</th>
                    <td>{reservations.customerName}</td>
                    <td>{reservations.tableNumber}</td>
                    <td>{reservations.date}</td>
                    <td>{reservations.time}</td>
                    <td>{reservations.partySize}</td>
                    <td>
                      {reservations?.specialRequests
                        ? reservations?.specialRequests
                        : "-"}
                    </td>

                    <td
                      className={`${
                        reservations.status.toLowerCase() === "confirmed"
                          ? "text-green-600"
                          : reservations.status.toLowerCase() === "pending"
                          ? "text-yellow-600"
                          : reservations.status.toLowerCase() === "cancelled"
                          ? "text-red-600"
                          : "text-black"
                      }`}
                    >
                      {reservations.status}
                    </td>
                  </tr>
                );
              }
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
